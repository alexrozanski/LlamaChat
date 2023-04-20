//
//  AvatarViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import Foundation
import Combine

class AvatarViewModel: ObservableObject {
  enum Avatar {
    case initials(String)
    case image(named: String)
  }

  @Published var avatar: Avatar

  private let chatSource: ChatSource

  init(chatSource: ChatSource) {
    self.chatSource = chatSource
    avatar = makeAvatar(for: chatSource.avatarImageName, name: chatSource.name)

    chatSource.$avatarImageName
      .combineLatest(chatSource.$name)
      .map { newAvatarImageName, newName in
        makeAvatar(for: newAvatarImageName, name: newName)
      }
      .assign(to: &$avatar)
  }
}

private func makeAvatar(for avatarImageName: String?, name: String) -> AvatarViewModel.Avatar {
  if let avatarImageName {
    return .image(named: avatarImageName)
  } else {
    let initials = String(name.components(separatedBy: .whitespacesAndNewlines).map({$0.prefix(1)}).joined(separator: ""))
    return .initials(initials)
  }
}
