//
//  ChatListItemViewModel.swift
//  
//
//  Created by Alex Rozanski on 08/05/2023.
//

import Foundation
import Combine
import DataModel

public class ChatListItemViewModel: ObservableObject {
  private let chatSource: ChatSource

  var id: String { chatSource.id }
  var modelDescription: String {
    return "\(chatSource.model.name)\(chatSource.modelVariant.map({ $0.name }) ?? "")"
  }
  @Published var title: String

  private var subscriptions = Set<AnyCancellable>()

  private(set) lazy var avatarViewModel = AvatarViewModel(chatSource: chatSource)

  private weak var chatListViewModel: ChatListViewModel?

  init(chatSource: ChatSource, chatListViewModel: ChatListViewModel) {
    self.chatSource = chatSource
    self.chatListViewModel = chatListViewModel
    self.title = chatSource.name
    chatSource.$name.sink(receiveValue: { [weak self] newName in
      self?.title = newName
    }).store(in: &subscriptions)
  }

  func remove() {
    chatListViewModel?.removeSource(chatSource)
  }
}
