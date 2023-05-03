//
//  ChatSource.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation
import Combine
public extension CodingUserInfoKey {
  static let defaultModelParametersProvider = CodingUserInfoKey(rawValue: "defaultModelParametersProvider")!
}

public class ChatSource: Codable, ObservableObject {
  public typealias ID = String
  public typealias DefaultModelParametersProvider = (_ type: ChatSourceType) -> ModelParameters

  public let id: ID

  @Published public var name: String
  @Published public var avatarImageName: String?

  public let type: ChatSourceType
  public let modelURL: URL
  public let modelDirectoryId: ModelDirectoryId?
  public let modelSize: ModelSize
  @Published public var modelParameters: ModelParameters
  @Published public var useMlock: Bool

  public let modelParametersDidChange = PassthroughSubject<Void, Never>()
  private var subscriptions = Set<AnyCancellable>()

  public init(
    name: String,
    avatarImageName: String?,
    type: ChatSourceType,
    modelURL: URL,
    modelDirectoryId: ModelDirectoryId?,
    modelSize: ModelSize,
    modelParameters: ModelParameters,
    useMlock: Bool
  ) {
    self.id = UUID().uuidString
    self.name = name
    self.avatarImageName = avatarImageName
    self.type = type
    self.modelURL = modelURL
    self.modelDirectoryId = modelDirectoryId
    self.modelSize = modelSize
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
    type = try values.decode(ChatSourceType.self, forKey: .type)
    modelURL = try values.decode(URL.self, forKey: .modelURL)
    modelDirectoryId = try values.decode(ModelDirectoryId?.self, forKey: .modelDirectoryId)
    modelSize = try values.decode(ModelSize.self, forKey: .modelSize)

    // These were added after the initial release.
    var modelParametersValue: ModelParameters?
    modelParametersValue = try values.decodeIfPresent(ModelParameters.self, forKey: .modelParameters)
    if modelParametersValue == nil {
      let defaultParametersProvider = decoder.userInfo[.defaultModelParametersProvider] as? DefaultModelParametersProvider
      modelParametersValue = defaultParametersProvider?(type)
    }
    guard let modelParametersValue else {
      throw DecodingError.keyNotFound(CodingKeys.modelParameters, .init(codingPath: [], debugDescription: "Model parameters key is missing"))
    }
    self.modelParameters = modelParametersValue
    let useMlock = try values.decodeIfPresent(Bool.self, forKey: .useMlock)
    self.useMlock = useMlock ?? false

    setUpPublishers()
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(name, forKey: .name)
    try container.encode(avatarImageName, forKey: .avatarImageName)
    try container.encode(type, forKey: .type)
    try container.encode(modelURL, forKey: .modelURL)
    try container.encode(modelDirectoryId, forKey: .modelDirectoryId)
    try container.encode(modelSize, forKey: .modelSize)
    try container.encode(modelParameters, forKey: .modelParameters)
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

    $modelParameters
      .map { $0.objectWillChange }
      .switchToLatest()
      .sink { [weak modelParametersDidChange] p in
        modelParametersDidChange?.send()
      }.store(in: &subscriptions)
  }
}
