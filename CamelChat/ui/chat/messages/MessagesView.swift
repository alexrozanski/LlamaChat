//
//  MessagesView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct MessagesView: View {
  @ObservedObject var viewModel: MessagesViewModel

  @State private var lastMessageId: UUID?

  var body: some View {
    GeometryReader { geometry in
      ScrollViewReader { proxy in
        ScrollView(.vertical) {
          LazyVStack {
            ForEach(viewModel.messages, id: \.id) { messageRowViewModel in
              MessageRowView(viewModel: messageRowViewModel, sender: messageRowViewModel.sender, maxWidth: geometry.size.width * 0.8) { messageViewModel in
                if let staticMessageViewModel = messageViewModel as? StaticMessageViewModel {
                  MessageBubbleView(sender: staticMessageViewModel.sender, style: .regular, isError: staticMessageViewModel.isError) {
                    Text(staticMessageViewModel.content)
                  }
                } else if let generatedMessageViewModel = messageViewModel as? GeneratedMessageViewModel {
                  GeneratedMessageView(viewModel: generatedMessageViewModel)
                } else {
                  EmptyView()
                }
              }
              .id(messageRowViewModel.id)
            }
          }
          .frame(maxWidth: .infinity)
          .padding()
        }
        .onAppear {
          lastMessageId = viewModel.messages.last?.id
          proxy.scrollTo(lastMessageId, anchor: .bottom)
        }
        .onReceive(viewModel.$messages) { newMessages in
          // No other way to implement this for now.
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            lastMessageId = viewModel.messages.last?.id
            withAnimation {
              proxy.scrollTo(lastMessageId, anchor: .bottom)
            }
          }
        }
      }
    }
    .background(Color(NSColor.controlBackgroundColor.cgColor))
  }
}
