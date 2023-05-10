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
      self?.handleSelectedSource(model: model, variant: variant)
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

  // MARK: - View Models

  private func makeConvertSourceViewModel(
    configuredSource: ConfiguredSource,
    validatedData: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>
  ) -> ConvertSourceViewModel {
    return ConvertSourceViewModel(
      data: validatedData,
      completionHandler: { [weak self] modelURL, modelDirectory in
        self?.add(
          source: ChatSource(
            name: "",
            avatarImageName: "",
            model: configuredSource.model,
            modelVariant: configuredSource.modelVariant,
            modelURL: modelURL,
            modelDirectoryId: modelDirectory.id,
            modelParameters: defaultModelParameters(),
            useMlock: false
          )
        )
      },
      cancelHandler: { [weak self] in self?.closeHandler(nil) }
    )
  }

  private func makeConfigureDetailsViewModel(
    configuredSource: ConfiguredSource
  ) -> ConfigureDetailsViewModel {
    return ConfigureDetailsViewModel(
      configuredSource: configuredSource
    )
  }

  // MARK: - Handlers

  private func handleSelectedSource(model: Model, variant: ModelVariant?) {
    navigationPath.append(
      .configureModel(
        ConfigureModelViewModel(
          model: model,
          variant: variant,
          nextHandler: { [weak self] configuredSource in
            self?.handleConfiguredSource(configuredSource)
          }
        )
      )
    )
  }

  private func handleConfiguredSource(_ configuredSource: ConfiguredSource) {
    switch configuredSource.settings {
    case .ggmlModel(modelURL: let modelURL):
      navigationPath.append(
        .configureDetails(
          makeConfigureDetailsViewModel(configuredSource: configuredSource)
        )
      )
//      add(
//        source: ChatSource(
//          name: "",
//          avatarImageName: "",
//          model: source.model,
//          modelVariant: source.modelVariant,
//          modelURL: modelURL,
//          modelDirectoryId: nil,
//          modelParameters: defaultModelParameters(),
//          useMlock: false
//        )
//      )
    case .pyTorchCheckpoints(data: let validatedData):
      navigationPath.append(
        .convertPyTorchSource(
          makeConvertSourceViewModel(
            configuredSource: configuredSource,
            validatedData: validatedData
          )
        )
      )
    case .downloadedFile(fileURL: let fileURL):
      do {
        let modelDirectory = try ModelFileManager.shared.makeNewModelDirectory()
        let modelFileURL = try modelDirectory.moveFileIntoDirectory(from: fileURL)
        add(
          source: ChatSource(
            name: "",
            avatarImageName: "",
            model: configuredSource.model,
            modelVariant: configuredSource.modelVariant,
            modelURL: modelFileURL,
            modelDirectoryId: modelDirectory.id,
            modelParameters: defaultModelParameters(),
            useMlock: false
          )
        )
      } catch {
        print(error)
      }
    }
  }

  // MARK: - Actions

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
