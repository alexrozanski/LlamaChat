//
//  SetupViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation
import Combine

class SetupViewModel: ObservableObject {
  private let chatSources: ChatSources
  
  init(chatSources: ChatSources) {
    self.chatSources = chatSources
  }
}
