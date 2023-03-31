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
            MessageRowView(sender: messageViewModel.sender, maxWidth: geometry.size.width * 0.8) {
              if let staticMessageViewModel = messageViewModel as? StaticMessageViewModel {
                MessageBubbleView(sender: staticMessageViewModel.sender) {
                  Text(staticMessageViewModel.content)
                }
              } else if let generatedMessageViewModel = messageViewModel as? GeneratedMessageViewModel {
                GeneratedMessageView(viewModel: generatedMessageViewModel)
              } else {
                EmptyView()
              }
            }
          }
        }
        .frame(maxWidth: .infinity)
        .padding()
      }
    }
  }
}
