//
//  AddSourceViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import llama

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

  init(chatSources: ChatSources, closeHandler: @escaping CloseHandler) {
    self.chatSources = chatSources
    self.closeHandler = closeHandler
  }

  private func makeConfigureSourceViewModel(for sourceType: ChatSourceType) -> ConfigureSourceViewModel {
    let nextHandler: ConfigureLocalModelSourceViewModel.NextHandler = { [weak self] configuredSource in
      switch configuredSource.settings {
      case .ggmlModel(modelURL: let modelURL, modelSize: let modelSize):
        let source = ChatSource(
          name: configuredSource.name,
          type: sourceType,
          modelURL: modelURL,
          modelSize: modelSize
        )
        self?.add(source: source)
      case .pyTorchCheckpoints(data: let validatedData):
        self?.convertSourceViewModel = ConvertSourceViewModel(
          pipeline: makeConvertPyTorchConversionPipeline(for: validatedData),
          cancelHandler: { [weak self] in self?.closeHandler(nil) }
        )
        self?.navigationPath.append(.convertPyTorchSource)
      }
    }

    switch sourceType {
    case .llama:
      return makeConfigureLocalLlamaModelSourceViewModel(nextHandler: nextHandler)
    case .alpaca:
      return makeConfigureLocalAlpacaModelSourceViewModel(nextHandler:nextHandler)
    case .gpt4All:
      return makeConfigureLocalGPT4AllModelSourceViewModel(nextHandler:nextHandler)
    }
  }

  private func add(source: ChatSource) {
    chatSources.add(source: source)
    closeHandler(source)
  }
}

private func makeConvertPyTorchConversionPipeline(for validatedData: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>) -> ConversionPipeline {
  let modelConverter = ModelConverter()

  class PipelineData {
    var convertedModelURL: URL?
  }

  let pipelineData = PipelineData()
  return ConversionPipeline {
    return [
      ConvertStep(label: "Checking environment", withCommandConnectors: { commandConnectors in
        return try await modelConverter.canRunConversion(commandConnectors).exitCode
      }),
      ConvertStep(label: "Installing dependencies", withCommandConnectors: { commandConnectors in
        return try await modelConverter.installDependencies(commandConnectors).exitCode
      }),
      ConvertStep(label: "Checking dependencies", withCommandConnectors: { commandConnectors in
        return try await modelConverter.checkInstalledDependencies(commandConnectors).exitCode
      }),
      ConvertStep(label: "Converting model", withCommandConnectors: { commandConnectors in
        var result: ConvertPyTorchToGgmlConversionResult?
        let status = try await modelConverter.convert(with: validatedData, result: &result, commandConnectors: commandConnectors)
        switch status {
        case .success:
          pipelineData.convertedModelURL = result?.outputFileURL
        case .failure:
          break
        }
        return status.exitCode
      }),
      ConvertStep(label: "Quantizing model", withCommandConnectors: { commandConnectors in
        guard let convertedModelURL = pipelineData.convertedModelURL else { return 1 }

        let destinationModelURL = convertedModelURL.deletingLastPathComponent().appendingPathComponent("test")
        try await modelConverter.quantizeModel(from: convertedModelURL, to: destinationModelURL)
        return 0
      })
    ]
  }
}
