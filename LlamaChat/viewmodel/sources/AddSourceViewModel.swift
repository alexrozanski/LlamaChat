//
//  AddSourceViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import CameLLM
import CameLLMLlama

enum AddSourceStep: Hashable {
  case configureSource
  case convertPyTorchSource
}

class AddSourceViewModel: ObservableObject {
  typealias CloseHandler = (_ newChatSource: ChatSource?) -> Void

  private let chatSources: ChatSources
  private let closeHandler: CloseHandler

  @Published var navigationPath = [AddSourceStep]()

  private(set) lazy var selectSourceTypeViewModel: SelectSourceTypeViewModel = {
    return SelectSourceTypeViewModel(chatSources: chatSources) { [weak self] sourceType in
      self?.configureSourceViewModel = self?.makeConfigureSourceViewModel(for: sourceType)
      self?.navigationPath.append(.configureSource)
    }
  }()

  private(set) var configureSourceViewModel: ConfigureSourceViewModel?
  private(set) var convertSourceViewModel: ConvertSourceViewModel?

  private var addedModel = false

  init(chatSources: ChatSources, closeHandler: @escaping CloseHandler) {
    self.chatSources = chatSources
    self.closeHandler = closeHandler
  }

  deinit {
    if !addedModel {
      convertSourceViewModel?.cleanUp_DANGEROUS()
    }
  }

  func cancel() {
    closeHandler(nil)
  }

  // MARK: - Private

  private func makeConfigureSourceViewModel(for sourceType: ChatSourceType) -> ConfigureSourceViewModel? {
    let nextHandler: ConfigureSourceNextHandler = { [weak self] configuredSource in
      guard let self else { return }

      switch configuredSource.settings {
      case .ggmlModel(modelURL: let modelURL, modelSize: let modelSize):
        self.add(
          source: ChatSource(
            name: configuredSource.name,
            avatarImageName: configuredSource.avatarImageName,
            type: sourceType,
            modelURL: modelURL,
            modelDirectoryId: nil,
            modelSize: modelSize,
            modelParameters: defaultModelParameters(for: sourceType),
            useMlock: false
          )
        )
      case .pyTorchCheckpoints(data: let validatedData, let modelSize):
        self.convertSourceViewModel = self.makeConvertSourceViewModel(
          with: sourceType,
          configuredSource: configuredSource,
          modelSize: modelSize,
          validatedData: validatedData
        )
        self.navigationPath.append(.convertPyTorchSource)
      case .downloadedFile(fileURL: let fileURL, modelSize: let modelSize):
        do {
          let modelDirectory = try ModelFileManager.shared.makeNewModelDirectory()
          let modelFileURL = try modelDirectory.moveFileIntoDirectory(from: fileURL)
          self.add(
            source: ChatSource(
              name: configuredSource.name,
              avatarImageName: configuredSource.avatarImageName,
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

    switch sourceType {
    case .llama:
      return ConfigureLocalModelSourceViewModel(
        defaultName: "LLaMA",
        chatSourceType: ChatSourceType.llama,
        exampleGgmlModelPath: "ggml-model-q4_0.bin",
        nextHandler: nextHandler
      )
    case .alpaca:
      return ConfigureLocalModelSourceViewModel(
        defaultName: "Alpaca",
        chatSourceType: ChatSourceType.alpaca,
        exampleGgmlModelPath: "ggml-alpaca-7b-q4.bin",
        nextHandler: nextHandler
      )
    case .gpt4All:
      guard let url = URL(string: "https://gpt4all.io/ggml-gpt4all-j.bin") else { return nil }
      return ConfigureDownloadableModelSourceViewModel(
        defaultName: "GPT4All",
        chatSourceType: ChatSourceType.gpt4All,
        modelSize: .size7B,
        downloadURL: url,
        nextHandler: nextHandler
      )
    }
  }

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

  private func add(source: ChatSource) {
    guard !addedModel else { return }

    chatSources.add(source: source)
    addedModel = true
    closeHandler(source)
  }
}
