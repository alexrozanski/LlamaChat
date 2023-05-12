//
//  AvatarViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import Foundation
import Combine
import DataModel

public class AvatarViewModel: ObservableObject {
  public enum Avatar {
    case initials(String)
    case image(named: String)
  }

  @Published public var avatar: Avatar

  private let chatSource: ChatSource

  public init(chatSource: ChatSource) {
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
    let initials = String(name.components(separatedBy: .whitespacesAndNewlines)
      .map { $0.prefix(1) }
      .filter { CharacterSet.alphanumerics.isSuperset(of: CharacterSet(charactersIn: String($0))) }
      .joined(separator: ""))
    return .initials(initials)
  }
}