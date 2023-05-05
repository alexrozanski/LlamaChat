//
//  AddSourceFlowPresentationStyle.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import Foundation

struct AddSourceFlowPresentationStyle {
  let showTitle: Bool
  let showBackButton: Bool

  private init(showTitle: Bool, showBackButton: Bool) {
    self.showTitle = showTitle
    self.showBackButton = showBackButton
  }

  static var standalone = AddSourceFlowPresentationStyle(showTitle: true, showBackButton: true)
  static var embedded = AddSourceFlowPresentationStyle(showTitle: false, showBackButton: false)
}
