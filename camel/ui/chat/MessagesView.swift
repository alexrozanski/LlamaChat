//
//  MessagesView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct MessagesView: View {
  @ObservedObject var viewModel: MessagesViewModel

  var body: some View {
    GeometryReader { geometry in
      ScrollView(.vertical) {
        VStack {
          ForEach(viewModel.messages, id: \.id) { messageViewModel in
            MessageBubbleView(viewModel: messageViewModel)
          }
        }
        .frame(maxWidth: .infinity)
        .padding()
      }
    }
  }
}
