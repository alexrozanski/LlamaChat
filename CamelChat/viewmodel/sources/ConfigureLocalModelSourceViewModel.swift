//
//  ConfigureLocalModelSourceViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import llama

private func getInvalidModelTypeReason(from error: Error) -> ConfigureLocalModelSourceViewModel.InvalidModelTypeReason {
  print(error)

  // Reason is always stored in the underlying error
  guard let underlyingError = ((error as NSError).underlyingErrors as [NSError]).first(where: { $0.domain == LlamaError.Domain }) else {
    return .unknown
  }

  if underlyingError.code == LlamaError.Code.invalidModelBadMagic.rawValue {
    return .invalidFileType
  }

  if underlyingError.code == LlamaError.Code.invalidModelUnversioned.rawValue || underlyingError.code == LlamaError.Code.invalidModelUnsupportedFileVersion.rawValue {
    return .unsupportedModelVersion
  }

  return .unknown
}

class ConfigureLocalModelSourceViewModel: ObservableObject, ConfigureSourceViewModel {
  typealias AddSourceHandler = (ChatSource) -> Void
  typealias GoBackHandler = () -> Void

  private lazy var nameGenerator = SourceNameGenerator()

  @Published var name: String {
    didSet {
      validate()
    }
  }
  @Published var modelPath: String? {
    didSet {
      guard let modelPath = modelPath, FileManager().fileExists(atPath: modelPath) else {
        modelState = .invalidPath
        return
      }

      do {
        try ModelUtils.validateModel(fileURL: URL(fileURLWithPath: modelPath))
      } catch {
        print(error)
        modelState = .invalidModel(getInvalidModelTypeReason(from: error))
        return
      }

      modelState = .valid

      do {
        let type = try ModelUtils.getModelType(forFileAt: URL(fileURLWithPath: modelPath))
        switch type {
        case .unknown: modelSize = .unknown
        case .size7B: modelSize = .size7B
        case .size12B: modelSize = .size12B
        case .size30B: modelSize = .size30B
        case .size65B: modelSize = .size65B
        }
      } catch {
        print(error)
      }
    }
  }
  @Published var canContinue: Bool = false

  var modelType: String {
    return chatSourceType.readableName
  }
  var exampleModelPath: String

  enum InvalidModelTypeReason {
    case unknown
    case invalidFileType
    case unsupportedModelVersion
  }

  enum ModelState {
    case none
    case invalidPath
    case invalidModel(_ reason: InvalidModelTypeReason)
    case valid

    var isValid: Bool {
      switch self {
      case .none, .invalidPath, .invalidModel:
        return false
      case .valid:
        return true
      }
    }
  }

  @Published private(set) var modelState: ModelState = .none {
    didSet {
      validate()
    }
  }

  @Published var modelSize: ModelSize = .unknown

  let navigationViewModel: ConfigureSourceNavigationViewModel

  let chatSourceType: ChatSourceType
  private let addSourceHandler: AddSourceHandler
  private let goBackHandler: GoBackHandler

  init(
    defaultName: String? = nil,
    chatSourceType: ChatSourceType,
    exampleModelPath: String,
    addSourceHandler: @escaping AddSourceHandler,
    goBackHandler: @escaping GoBackHandler
  ) {
    self.name = defaultName ?? ""
    self.chatSourceType = chatSourceType
    self.exampleModelPath = exampleModelPath
    self.addSourceHandler = addSourceHandler
    self.goBackHandler = goBackHandler
    navigationViewModel = ConfigureSourceNavigationViewModel()
    navigationViewModel.delegate = self
  }

  private func validate() {
    navigationViewModel.canContinue = modelState.isValid && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  func generateName() {
    if let generatedName = nameGenerator.generateName(for: chatSourceType) {
      name = generatedName
    }
  }
}

extension ConfigureLocalModelSourceViewModel: ConfigureSourceNavigationViewModelDelegate {
  func goBack() {
    goBackHandler()
  }

  func next() {
    guard let modelPath else { return }
    addSourceHandler(ChatSource(name: name, type: chatSourceType, modelURL: URL(fileURLWithPath: modelPath), modelSize: modelSize))
  }
}
