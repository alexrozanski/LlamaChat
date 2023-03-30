//
//  ChatSources.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

class ChatSources: ObservableObject {
  @Published private(set) var sources: [ChatSource] = []
}
