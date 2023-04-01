//
//  ConfigureAlpacaSourceViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

class ConfigureAlpacaSourceViewModel: ObservableObject, ConfigureSourceViewModel {
  typealias AddSourceHandler = (ChatSource) -> Void
  typealias GoBackHandler = () -> Void

  @Published var canContinue = false

  private let addSourceHandler: AddSourceHandler
  private let goBackHandler: GoBackHandler

  let navigationViewModel: ConfigureSourceNavigationViewModel

  init(addSourceHandler: @escaping AddSourceHandler, goBackHandler: @escaping GoBackHandler) {
    self.addSourceHandler = addSourceHandler
    self.goBackHandler = goBackHandler
    navigationViewModel = ConfigureSourceNavigationViewModel()
    navigationViewModel.delegate = self
  }
}

extension ConfigureAlpacaSourceViewModel: ConfigureSourceNavigationViewModelDelegate {
  func goBack() {
    goBackHandler()
  }

  func next() {
  }
}
