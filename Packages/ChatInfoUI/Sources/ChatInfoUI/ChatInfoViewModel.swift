//
//  ChatInfoViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import Foundation
import Combine
import AppModel
import DataModel
import SettingsUI
import SharedUI

public class ChatInfoViewModel: ObservableObject {
  private let chatModel: ChatModel

  var sourceId: ChatSource.ID {
    return chatModel.source.id
  }

  var name: String {
    return chatModel.source.name
  }
  
  var modelVariant: String? {
    return chatModel.source.modelVariant?.name
  }

  var modelName: String {
    return chatModel.source.model.name
  }
  
  @Published private(set) var canClearMessages: Bool

  private(set) lazy var avatarViewModel = AvatarViewModel(chatSource: chatModel.source)

  public init(chatModel: ChatModel) {
    self.chatModel = chatModel

    canClearMessages = !chatModel.messages.isEmpty

    chatModel
      .$messages
      .map { !$0.isEmpty }
      .assign(to: &$canClearMessages)
  }

  func clearMessages() {
    Task.init {
      await chatModel.clearMessages()
    }
  }

  func showInfo() {
    SettingsWindowPresenter.shared.present(deeplinkingTo: .sources(sourceId: chatModel.source.id, sourcesTab: .properties))
  }
}
