//
//  AvatarViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import Foundation
import Combine

class AvatarViewModel: ObservableObject {
  @Published var initials: String

  private let chatSource: ChatSource

  private var subscriptions = Set<AnyCancellable>()

  init(chatSource: ChatSource) {
    self.chatSource = chatSource
    initials = makeInitials(for: chatSource.name)
    chatSource.$name.sink(receiveValue: { newName in
      self.initials = makeInitials(for: newName)
    }).store(in: &subscriptions)
  }
}

private func makeInitials(for name: String) -> String {
  return String(name.components(separatedBy: .whitespacesAndNewlines).map({$0.prefix(1)}).joined(separator: ""))
}
