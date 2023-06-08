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
import ModelCompatibility
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
    validatedData: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>,
    variant: ModelVariant?
  ) -> ConvertSourceViewModel {
    return ConvertSourceViewModel(
      data: validatedData,
      completionHandler: { [weak self] modelURL, modelDirectory in
        self?.add(
          source: ChatSource(
            name: "",
            avatarImageName: "",
            model: configuredSource.model,
            modelVariant: variant,
            modelURL: modelURL,
            modelDirectoryId: modelDirectory.id,
            modelParameters: DefaultModelParametersProvider.defaultParameters(for: configuredSource.model, variant: variant),
            useMlock: false
          )
        )
      },
      cancelHandler: { [weak self] in self?.closeHandler(nil) }
    )
  }

  private func makeConfigureDetailsViewModel(
    configuredSource: ConfiguredSource,
    modelDirectoryId: ModelDirectory.ID?,
    modelURL: URL,
    variant: ModelVariant?
  ) -> ConfigureDetailsViewModel {
    return ConfigureDetailsViewModel(
      configuredSource: configuredSource,
      nextHandler: { [weak self] details in
        self?.add(
          source: ChatSource(
            name: details.name,
            avatarImageName: details.avatarImageName,
            model: configuredSource.model,
            modelVariant: variant,
            modelURL: modelURL,
            modelDirectoryId: modelDirectoryId,
            modelParameters: DefaultModelParametersProvider.defaultParameters(for: configuredSource.model, variant: variant),
            useMlock: false
          )
        )
      }
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
    case .ggmlModel(modelURL: let modelURL, variant: let modelVariant):
      navigationPath.append(
        .configureDetails(
          makeConfigureDetailsViewModel(
            configuredSource: configuredSource,
            modelDirectoryId: nil,
            modelURL: modelURL,
            variant: modelVariant
          )
        )
      )
    case .pyTorchCheckpoints(data: let validatedData, variant: let modelVariant):
      navigationPath.append(
        .convertPyTorchSource(
          makeConvertSourceViewModel(
            configuredSource: configuredSource,
            validatedData: validatedData,
            variant: modelVariant
          )
        )
      )
    case .downloadedFile(fileURL: let fileURL, variant: let modelVarient):
      do {
        let modelDirectory = try ModelFileManager.shared.makeNewModelDirectory()
        let modelFileURL = try modelDirectory.moveFileIntoDirectory(from: fileURL)
        navigationPath.append(
          .configureDetails(
            makeConfigureDetailsViewModel(
              configuredSource: configuredSource,
              modelDirectoryId: modelDirectory.id,
              modelURL: modelFileURL,
              variant: modelVarient
            )
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
