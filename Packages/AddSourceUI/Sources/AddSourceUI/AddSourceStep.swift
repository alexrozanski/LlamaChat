//
//  AddSourceStep.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation

enum AddSourceStep: Hashable, Equatable {
  case configureLocal(ConfigureLocalModelViewModel)
  case configureRemote(ConfigureDownloadableModelViewModel)
  case convertPyTorchSource(ConvertSourceViewModel)

  static func == (lhs: AddSourceStep, rhs: AddSourceStep) -> Bool {
    switch lhs {
    case .configureLocal(let lhsViewModel):
      switch rhs {
      case .configureLocal(let rhsViewModel):
        return lhsViewModel === rhsViewModel
      case .configureRemote, .convertPyTorchSource:
        return false
      }
    case .configureRemote(let lhsViewModel):
      switch rhs {
      case .configureRemote(let rhsViewModel):
        return lhsViewModel === rhsViewModel
      case .configureLocal, .convertPyTorchSource:
        return false
      }
    case .convertPyTorchSource(let lhsViewModel):
      switch rhs {
      case .convertPyTorchSource(let rhsViewModel):
        return lhsViewModel === rhsViewModel
      case .configureLocal, .configureRemote:
        return false
      }
    }
  }

  // We can't conform to RawRepresentable because we have associated values, but
  // we can use this as a basis for the 'base' type of the enum.
  private var rawValue: Int {
    switch self {
    case .configureLocal: return 0
    case .configureRemote: return 1
    case .convertPyTorchSource: return 2
    }
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(rawValue)
    switch self {
    case .configureLocal(let viewModel):
      hasher.combine(ObjectIdentifier(viewModel))
    case .configureRemote(let viewModel):
      hasher.combine(ObjectIdentifier(viewModel))
    case .convertPyTorchSource(let viewModel):
      hasher.combine(ObjectIdentifier(viewModel))
    }
  }
}

extension Array where Element == AddSourceStep {
  var convertViewModel: ConvertSourceViewModel? {
    return compactMap { element in
      switch element {
      case .convertPyTorchSource(let viewModel):
        return viewModel
      case .configureLocal, .configureRemote:
        return nil
      }
    }
    .first
  }
}
