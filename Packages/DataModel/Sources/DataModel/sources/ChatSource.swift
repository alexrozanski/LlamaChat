//
//  ChatSource.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation
import Combine

public extension CodingUserInfoKey {
  static let modelParametersCoder = CodingUserInfoKey(rawValue: "modelParametersCoder")!
  static let chatSourceUpgrader = CodingUserInfoKey(rawValue: "chatSourceUpgrader")!
}

enum ChatSourceCodingError: Error {
  case missingModelParametersCoder
  case missingChatSourceUpgrader
}

public class ChatSource: Codable, ObservableObject {
  public typealias ID = String
  public let id: ID

  @Published public var name: String
  @Published public var avatarImageName: String?

  public let modelId: String
  @Published public var model: Model?
  public let modelVariantId: String?
  @Published public var modelVariant: ModelVariant?

  public let modelURL: URL
  public let modelDirectoryId: ModelDirectoryId?
  @Published public var modelParameters: ModelParameters?
  @Published public var useMlock: Bool

  public let modelParametersDidChange = PassthroughSubject<Void, Never>()
  private var subscriptions = Set<AnyCancellable>()

  public init(
    name: String,
    avatarImageName: String?,
    model: Model,
    modelVariant: ModelVariant?,
    modelURL: URL,
    modelDirectoryId: ModelDirectoryId?,
    modelParameters: ModelParameters,
    useMlock: Bool
  ) {
    self.id = UUID().uuidString
    self.name = name
    self.avatarImageName = avatarImageName
    self.modelId = model.id
    self.model = model
    self.modelVariantId = modelVariant?.id
    self.modelVariant = modelVariant
    self.modelURL = modelURL
    self.modelDirectoryId = modelDirectoryId
    self.modelParameters = modelParameters
    self.useMlock = useMlock

    setUpPublishers()
  }

  // MARK: - Codable

  public enum CodingKeys: CodingKey {
    case id
    case name
    case avatarImageName
    case type
    case modelId
    case modelVariantId
    case modelURL
    case modelDirectoryId
    case modelSize
    case modelParameters
    case useMlock
  }

  public required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    id = try values.decode(String.self, forKey: .id)
    name = try values.decode(String.self, forKey: .name)
    avatarImageName = try values.decode(String?.self, forKey: .avatarImageName)
    modelURL = try values.decode(URL.self, forKey: .modelURL)
    modelDirectoryId = try values.decode(ModelDirectoryId?.self, forKey: .modelDirectoryId)

    guard let coder = decoder.userInfo[.modelParametersCoder] as? ModelParametersCoder else {
      throw ChatSourceCodingError.missingModelParametersCoder
    }

    modelParameters = try coder.decodeParameters(in: values, forKey: CodingKeys.modelParameters)

    guard let chatSourceUpgrader = decoder.userInfo[.chatSourceUpgrader] as? ChatSourceUpgrader else {
      throw ChatSourceCodingError.missingChatSourceUpgrader
    }

    let chatSourceTypeString = try values.decodeIfPresent(String.self, forKey: .type)
    let modelSizeString = try values.decodeIfPresent(String.self, forKey: .modelSize)
    let modelId = try values.decodeIfPresent(String.self, forKey: .modelId)
    let modelVariantId = try values.decodeIfPresent(String.self, forKey: .modelVariantId)

    model = nil
    modelVariant = nil

    if let modelId {
      self.modelId = modelId
      self.modelVariantId = modelVariantId
    } else {
      guard let chatSourceTypeString, let modelSizeString else {
        throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "missing type, modelSize keys needed for upgrade"))
      }

      let upgradedModelMetadata = try chatSourceUpgrader.upgradeChatSourceToModel(
        chatSourceType: chatSourceTypeString,
        modelSize: modelSizeString
      )
      self.modelId = upgradedModelMetadata.modelId
      self.modelVariantId = upgradedModelMetadata.modelVariantId
    }

    let useMlock = try values.decodeIfPresent(Bool.self, forKey: .useMlock)
    self.useMlock = useMlock ?? false

    setUpPublishers()
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(name, forKey: .name)
    try container.encode(avatarImageName, forKey: .avatarImageName)
    try container.encode(modelId, forKey: .modelId)
    try container.encode(modelVariantId, forKey: .modelVariantId)
    try container.encode(modelURL, forKey: .modelURL)
    try container.encode(modelDirectoryId, forKey: .modelDirectoryId)

    guard let coder = encoder.userInfo[.modelParametersCoder] as? ModelParametersCoder else {
      throw ChatSourceCodingError.missingModelParametersCoder
    }

    if let modelParameters {
      try coder.encode(parameters: modelParameters, to: &container, forKey: .modelParameters)
    }

    try container.encode(useMlock, forKey: .useMlock)
  }

  // MARK: - Private

  private func setUpPublishers() {
    $useMlock
      .sink { newValue in
        self.modelParametersDidChange.send()
      }.store(in: &subscriptions)

    $modelParameters
      .dropFirst()
      .sink { [weak modelParametersDidChange] _ in
        modelParametersDidChange?.send()
      }.store(in: &subscriptions)

//    $modelParameters
//      .map { $0.objectWillChange }
//      .switchToLatest()
//      .sink { [weak modelParametersDidChange] p in
//        modelParametersDidChange?.send()
//      }.store(in: &subscriptions)
  }
}
