//
//  MessageViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import Combine

protocol MessageViewModel {
  var id: UUID { get }

  var canCopyContents: CurrentValueSubject<Bool, Never> { get }

  func copyContents()
}

class ObservableMessageViewModel: ObservableObject {
  private let wrapped: MessageViewModel
  private var subscriptions = Set<AnyCancellable>()

  @Published var canCopyContents: Bool

  var id: UUID { wrapped.id}

  init(_ wrapped: MessageViewModel) {
    self.wrapped = wrapped
    self.canCopyContents = wrapped.canCopyContents.value
    wrapped.canCopyContents
      .sink { [weak self] newCanCopyContents in self?.canCopyContents = newCanCopyContents }
      .store(in: &subscriptions)
  }

  func copyContents() {
    wrapped.copyContents()
  }

  func getUnderlyingViewModel() -> MessageViewModel {
    return wrapped
  }

  func get<T>() -> T? {
    return wrapped as? T
  }
}

extension ObservableMessageViewModel: Equatable {
  static func == (lhs: ObservableMessageViewModel, rhs: ObservableMessageViewModel) -> Bool {
    return lhs.id == rhs.id
  }

}
