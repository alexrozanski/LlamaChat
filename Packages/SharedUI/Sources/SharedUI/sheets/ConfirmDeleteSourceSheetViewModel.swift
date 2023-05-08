//
//  ConfirmDeleteSourceSheetViewModel.swift
//  
//
//  Created by Alex Rozanski on 08/05/2023.
//

import Foundation
import AppModel
import DataModel

public class ConfirmDeleteSourceSheetViewModel: ObservableObject {
  let chatSource: ChatSource
  let chatSourcesModel: ChatSourcesModel
  private let closeHandler: () -> Void

  public init(
    chatSource: ChatSource,
    chatSourcesModel: ChatSourcesModel,
    closeHandler: @escaping () -> Void
  ) {
    self.chatSource = chatSource
    self.chatSourcesModel = chatSourcesModel
    self.closeHandler = closeHandler
  }

  func cancel() {
    closeHandler()
  }

  func delete() {
    chatSourcesModel.remove(source: chatSource)
    closeHandler()
  }
}
