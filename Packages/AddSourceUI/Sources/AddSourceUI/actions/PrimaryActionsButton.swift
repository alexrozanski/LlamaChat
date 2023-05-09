//
//  PrimaryActionsButton.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import Foundation

class PrimaryActionsButton {
  typealias Action = () -> Void

  let title: String
  let disabled: Bool
  let action: () -> Void

  init(title: String, disabled: Bool = false, action: @escaping Action) {
    self.title = title
    self.disabled = disabled
    self.action = action
  }
}
