//
//  AddSourceViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import AppModel
import CameLLM
import CameLLMLlama
import AppModel
import DataModel
import ModelUtils
import ModelDirectory

public class AddSourceViewModel: ObservableObject {
  public typealias CloseHandler = (_ newChatSource: ChatSource?) -> Void

  private let dependencies: Dependencies
  private let closeHandler: CloseHandler

  @Published var navigationPath = [AddSourceStep]()

  private(set) lazy var selectSourceTypeViewModel: SelectSourceTypeViewModel = {
    return SelectSourceTypeViewModel(dependencies: dependencies) { [weak self] model, variant in
      let step: AddSourceStep
      switch model.source {
      case .local:
        step = .configureLocal(
          ConfigureLocalModelSourceViewModel(
            defaultName: model.name,
            model: model,
            exampleGgmlModelPath: "ggml-model-q4_0.bin",
            nextHandler: { _ in }
          )
        )
      case .remote:
        guard let variant, let downloadURL = variant.downloadUrl else { return }

        step = .configureRemote(
          ConfigureRemoteModelSourceViewModel(
            defaultName: model.name,
            chatSourceType: ChatSourceType.gpt4All,
            model: model,
            modelVariant: variant,
            modelSize: .size7B,
            downloadURL: downloadURL,
            nextHandler: { _ in }
          )
        )
      }

      self?.navigationPath.append(step)
    }
  }()

  private var addedModel = false

  public init(dependencies: Dependencies, closeHandler: @escaping CloseHandler) {
    self.dependencies = dependencies
    self.closeHandler = closeHandler
  }

  func cancel() {
    closeHandler(nil)
  }

  // MARK: - Private

  private func makeConvertSourceViewModel(
    with sourceType: ChatSourceType,
    configuredSource: ConfiguredSource,
    modelSize: ModelSize,
    validatedData: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>
  ) -> ConvertSourceViewModel {
    return ConvertSourceViewModel(
      data: validatedData,
      completionHandler: { [weak self] modelURL, modelDirectory in
        self?.add(
          source: ChatSource(
            name: configuredSource.name,
            avatarImageName: configuredSource.avatarImageName,
            type: sourceType,
            modelURL: modelURL,
            modelDirectoryId: modelDirectory.id,
            modelSize: modelSize,
            modelParameters: defaultModelParameters(for: sourceType),
            useMlock: false
          )
        )
      },
      cancelHandler: { [weak self] in self?.closeHandler(nil) }
    )
  }

  private func handleConfiguredSource(source: ConfiguredSource, sourceType: ChatSourceType) {
    switch source.settings {
    case .ggmlModel(modelURL: let modelURL, modelSize: let modelSize):
      self.add(
        source: ChatSource(
          name: source.name,
          avatarImageName: source.avatarImageName,
          type: sourceType,
          modelURL: modelURL,
          modelDirectoryId: nil,
          modelSize: modelSize,
          modelParameters: defaultModelParameters(for: sourceType),
          useMlock: false
        )
      )
    case .pyTorchCheckpoints(data: let validatedData, let modelSize):
      self.navigationPath.append(
        .convertPyTorchSource(
          self.makeConvertSourceViewModel(
            with: sourceType,
            configuredSource: source,
            modelSize: modelSize,
            validatedData: validatedData
          )
        )
      )
    case .downloadedFile(fileURL: let fileURL, modelSize: let modelSize):
      do {
        let modelDirectory = try ModelFileManager.shared.makeNewModelDirectory()
        let modelFileURL = try modelDirectory.moveFileIntoDirectory(from: fileURL)
        self.add(
          source: ChatSource(
            name: source.name,
            avatarImageName: source.avatarImageName,
            type: sourceType,
            modelURL: modelFileURL,
            modelDirectoryId: modelDirectory.id,
            modelSize: modelSize,
            modelParameters: defaultModelParameters(for: sourceType),
            useMlock: false
          )
        )
      } catch {
        print(error)
      }
    }
  }

  private func add(source: ChatSource) {
    guard !addedModel else { return }

    dependencies.chatSourcesModel.add(source: source)

    // This is important -- otherwise we will delete the model. Refactor this to not be
    // as dangerous.
    navigationPath.convertViewModel?.markModelKept()
    addedModel = true
    closeHandler(source)
  }
}
