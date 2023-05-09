//
//  AddSourceStep.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation

enum AddSourceStep: Hashable, Equatable {
  case configureModel(ConfigureModelViewModel)
  case configureLocal(ConfigureLocalModelViewModel)
  case configureRemote(ConfigureDownloadableModelViewModel)
  case convertPyTorchSource(ConvertSourceViewModel)

  static func == (lhs: AddSourceStep, rhs: AddSourceStep) -> Bool {
    switch lhs {
    case .configureModel(let lhsViewModel):
      switch rhs {
      case .configureModel(let rhsViewModel):
        return lhsViewModel === rhsViewModel
      case .configureLocal, .configureRemote, .convertPyTorchSource:
        return false
      }
    case .configureLocal(let lhsViewModel):
      switch rhs {
      case .configureLocal(let rhsViewModel):
        return lhsViewModel === rhsViewModel
      case .configureModel, .configureRemote, .convertPyTorchSource:
        return false
      }
    case .configureRemote(let lhsViewModel):
      switch rhs {
      case .configureRemote(let rhsViewModel):
        return lhsViewModel === rhsViewModel
      case .configureModel, .configureLocal, .convertPyTorchSource:
        return false
      }
    case .convertPyTorchSource(let lhsViewModel):
      switch rhs {
      case .convertPyTorchSource(let rhsViewModel):
        return lhsViewModel === rhsViewModel
      case .configureModel, .configureLocal, .configureRemote:
        return false
      }
    }
  }

  // We can't conform to RawRepresentable because we have associated values, but
  // we can use this as a basis for the 'base' type of the enum.
  private var rawValue: Int {
    switch self {
    case .configureModel: return 0
    case .configureLocal: return 1
    case .configureRemote: return 2
    case .convertPyTorchSource: return 3
    }
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(rawValue)
    switch self {
    case .configureModel(let viewModel):
      hasher.combine(ObjectIdentifier(viewModel))
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
      case .configureModel, .configureLocal, .configureRemote:
        return nil
      }
    }
    .first
  }
}
