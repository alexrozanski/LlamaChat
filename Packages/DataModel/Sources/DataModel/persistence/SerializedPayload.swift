//
//  SerializedPayload.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 21/04/2023.
//

import Foundation

// Defines a Codable payload type which stores some nested Codable data alongside information
// about the payload itself as well as the app version which created it.
//
// This is useful if opening a version of LlamaChat with data that was serialized by a newer version
// and we can handle these cases more gracefully, including displaying which app version serialized
// the data.
open class SerializedPayload<T>: Codable where T: Codable {
  public let value: T
  public let payloadVersion: Int
  // Info about the version of the app which wrote this payload.
  public let serializingAppVersion: Int?
  public let serializingAppShortVersionString: String?

  // Override these in subclasses.
  open class var valueKey: String? { return nil }
  open class var currentPayloadVersion: Int { return -1 }

  // Unfortunately because the `value` key is dynamic we have to implement this struct ourselves.
  public struct CodingKeys: CodingKey {
    enum Key {
      case value(String?)
      case payloadVersion
      case serializingAppVersion
      case serializingAppShortVersionString

      init(string: String) {
        switch string {
        case "payloadVersion": self = .payloadVersion
        case "serializingAppVersion": self = .serializingAppVersion
        case "serializingAppShortVersionString": self = .serializingAppShortVersionString
        // This only works because there is one non-static key.
        default: self = .value(string)
        }
      }

      var stringValue: String {
        switch self {
        case .value(let key): return key ?? "value"
        case .payloadVersion: return "payloadVersion"
        case .serializingAppVersion: return "serializingAppVersion"
        case .serializingAppShortVersionString: return "serializingAppShortVersionString"
        }
      }
    }

    var key: Key
    static func key(_ key: Key) -> CodingKeys {
      return self.init(stringValue: key.stringValue)
    }

    // `CodingKey` cruft
    public var intValue: Int? { return nil }
    public init(stringValue: String) { self.key = .init(string: stringValue) }
    public init?(intValue: Int) { return nil }
    public var stringValue: String {
      return key.stringValue
    }
  }

  public init(value: T) {
    self.value = value
    self.payloadVersion = type(of: self).currentPayloadVersion
    self.serializingAppVersion = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String).flatMap { Int($0) }
    self.serializingAppShortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.value = try container.decode(T.self, forKey: .key(.value(type(of: self).valueKey)))
    let payloadVersion = try container.decodeIfPresent(Int.self, forKey: .key(.payloadVersion))
    // TODO: handle any upgrade work here?
    self.payloadVersion = payloadVersion ?? type(of: self).currentPayloadVersion
    self.serializingAppVersion = try container.decodeIfPresent(Int.self, forKey: .key(.serializingAppVersion))
    self.serializingAppShortVersionString = try container.decodeIfPresent(String.self, forKey: .key(.serializingAppShortVersionString))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(value, forKey: .key(.value(type(of: self).valueKey)))
    try container.encode(payloadVersion, forKey: .key(.payloadVersion))
    try container.encode(serializingAppVersion, forKey: .key(.serializingAppVersion))
    try container.encode(serializingAppShortVersionString, forKey: .key(.serializingAppShortVersionString))
  }
}
