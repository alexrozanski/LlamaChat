//
//  ConfigureDownloadableModelSourceViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import Foundation
import Combine
import SwiftUI

class ConfigureDownloadableModelSourceViewModel: ObservableObject, ConfigureSourceViewModel {
  typealias NextHandler = (ConfiguredSource) -> Void

  let chatSourceType: ChatSourceType
  let primaryActionsViewModel = ConfigureSourcePrimaryActionsViewModel()
  private let nextHandler: NextHandler

  private var subscriptions = Set<AnyCancellable>()

  init(
    chatSourceType: ChatSourceType,
    nextHandler: @escaping NextHandler
  ) {
    self.chatSourceType = chatSourceType
    self.nextHandler = nextHandler
    primaryActionsViewModel.delegate = self
  }
}

extension ConfigureDownloadableModelSourceViewModel: ConfigureSourcePrimaryActionsViewModelDelegate {
  func next() {
  }
}
