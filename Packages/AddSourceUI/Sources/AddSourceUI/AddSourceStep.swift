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
  case configureDetails(ConfigureDetailsViewModel)

  static func == (lhs: AddSourceStep, rhs: AddSourceStep) -> Bool {
    switch lhs {
    case .configureModel(let lhsViewModel):
      return lhsViewModel === rhs.configureModelViewModel
    case .configureLocal(let lhsViewModel):
      return lhsViewModel === rhs.configureLocalModelViewModel
    case .configureRemote(let lhsViewModel):
      return lhsViewModel === rhs.configureDownloadableModelViewModel
    case .convertPyTorchSource(let lhsViewModel):
      return lhsViewModel === rhs.convertSourceViewModel
    case .configureDetails(let lhsViewModel):
      return lhsViewModel === rhs.configureDetailsViewModel
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
    case .configureDetails: return 4
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
    case .configureDetails(let viewModel):
      hasher.combine(ObjectIdentifier(viewModel))
    }
  }

  var configureModelViewModel: ConfigureModelViewModel? {
    switch self {
    case .configureModel(let viewModel):
      return viewModel
    case .configureLocal, .configureRemote, .convertPyTorchSource, .configureDetails:
      return nil
    }
  }

  var configureLocalModelViewModel: ConfigureLocalModelViewModel? {
    switch self {
    case .configureLocal(let viewModel):
      return viewModel
    case .configureModel, .configureRemote, .convertPyTorchSource, .configureDetails:
      return nil
    }
  }

  var configureDownloadableModelViewModel: ConfigureDownloadableModelViewModel? {
    switch self {
    case .configureRemote(let viewModel):
      return viewModel
    case .configureModel, .configureLocal, .convertPyTorchSource, .configureDetails:
      return nil
    }
  }

  var convertSourceViewModel: ConvertSourceViewModel? {
    switch self {
    case .convertPyTorchSource(let viewModel):
      return viewModel
    case .configureModel, .configureLocal, .configureRemote, .configureDetails:
      return nil
    }
  }

  var configureDetailsViewModel: ConfigureDetailsViewModel? {
    switch self {
    case .configureDetails(let viewModel):
      return viewModel
    case .configureModel, .configureLocal, .configureRemote, .convertPyTorchSource:
      return nil
    }
  }
}

extension Array where Element == AddSourceStep {
  var convertViewModel: ConvertSourceViewModel? {
    return compactMap { $0.convertSourceViewModel }.first
  }
}
