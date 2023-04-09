//
//  StateRestoration.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation

protocol RestorableValue {}

extension String: RestorableValue {}
extension Int: RestorableValue {}
extension Double: RestorableValue {}
extension Bool: RestorableValue {}
extension Data: RestorableValue {}
extension Array: RestorableValue where Element == any RestorableValue {}
extension Dictionary: RestorableValue where Key == String, Value == any RestorableValue {}

protocol RestorableData<DomainKey> {
  associatedtype DomainKey

  func getValue<V: RestorableValue>(for key: DomainKey) -> V?
  func set<V: RestorableValue>(value: V?, for key: DomainKey)
}

fileprivate class DomainScopedRestorableData<DomainKey>: RestorableData where DomainKey: RawRepresentable, DomainKey.RawValue == String {
  private let domain: String
  private let stateRestoration: StateRestoration

  private lazy var restorationPayload: Dictionary<String, any RestorableValue> = {
    let persisted = stateRestoration.loadDictionaryValue(for: domain)
    return persisted ?? Dictionary<String, any RestorableValue>()
  }() {
    didSet {
      stateRestoration.set(dictionaryValue: restorationPayload, for: domain)
    }
  }

  init(domain: String, stateRestoration: StateRestoration) {
    self.domain = domain
    self.stateRestoration = stateRestoration
  }

  func getValue<V: RestorableValue>(for key: DomainKey) -> V? {
    return restorationPayload[key.rawValue] as? V
  }

  func set<V: RestorableValue>(value: V?, for key: DomainKey) {
    if let value {
      restorationPayload[key.rawValue] = value
    } else {
      restorationPayload.removeValue(forKey: key.rawValue)
    }
  }
}

// We're not using a Scene (so can't use SceneStorage) so build out this simple state restoration class.
class StateRestoration: ObservableObject {
  func restorableData<DomainKey>(for domain: String) -> any RestorableData<DomainKey> where DomainKey: RawRepresentable, DomainKey.RawValue == String {
    return DomainScopedRestorableData(domain: domain, stateRestoration: self)
  }

  private func defaultsKey(for key: String) -> String {
    return "restoration.\(key)"
  }

  fileprivate func loadDictionaryValue(for key: String) -> Dictionary<String, any RestorableValue>? {
    guard let rawDictionary = UserDefaults.standard.dictionary(forKey: defaultsKey(for: key)) else { return nil }
    return rawDictionary.compactMapValues(toRestorableValue(_:))
  }

  fileprivate func set(dictionaryValue: Dictionary<String, any RestorableValue>, for key: String) {
    UserDefaults.standard.setValue(dictionaryValue, forKey: defaultsKey(for: key))
  }

  fileprivate func set(value: any RestorableValue, for key: String) {
    UserDefaults.standard.setValue(value, forKey: defaultsKey(for: key))
  }
}

fileprivate func toRestorableValue(_ value: Any?) -> RestorableValue? {
  guard let value else { return nil }

  if let value = value as? String {
    return value
  }

  if let dictionaryValue = value as? NSDictionary {
    var dictionary = Dictionary<String, RestorableValue>()
    for (key, value) in dictionaryValue {
      if let key = key as? String {
        toRestorableValue(value).map { dictionary[key] = $0 }
      }
    }
    return dictionary
  }

  if let arrayValue = value as? NSArray {
    var array = Array<RestorableValue>()
    for value in arrayValue {
      toRestorableValue(value).map { array.append($0) }
    }
    return array
  }

  if let value = value as? NSNumber {
    let valueType = value.objCType.pointee
    if valueType == boolType {
      return value.boolValue
    } else if valueType == intType {
      return value.intValue
    } else if valueType == doubleType {
      return value.doubleValue
    } else {
      return nil
    }
  }

  return nil
}

fileprivate let boolType = NSNumber(booleanLiteral: true).objCType.pointee
fileprivate let intType = NSNumber(integerLiteral: 0).objCType.pointee
fileprivate let doubleType = NSNumber(floatLiteral: 0).objCType.pointee
