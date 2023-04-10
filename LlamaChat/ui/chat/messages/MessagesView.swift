//
//  MessagesView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct MessageView: View {
  @ObservedObject var viewModel: ObservableMessageViewModel
  let availableWidth: Double

  @ViewBuilder var messageView: some View {
    if let staticMessageViewModel: StaticMessageViewModel = viewModel.get() {
      MessageBubbleView(sender: staticMessageViewModel.sender, style: .regular, isError: staticMessageViewModel.isError, availableWidth: availableWidth * 0.8) {
        Text(staticMessageViewModel.content)
      }
    } else if let generatedMessageViewModel: GeneratedMessageViewModel = viewModel.get() {
      GeneratedMessageView(viewModel: generatedMessageViewModel, availableWidth: availableWidth * 0.8)
    } else if let clearedContextMessageViewModel: ClearedContextMessageViewModel = viewModel.get() {
      ClearedContextMessageView(viewModel: clearedContextMessageViewModel)
    } else {
      #if DEBUG
      Text("Missing row view for `\(String(describing: type(of: viewModel.getUnderlyingViewModel())))`")
        .padding()
      #else
      EmptyView()
      #endif
    }
  }

  var body: some View {
    messageView
      .contextMenu {
        if viewModel.canCopyContents {
          Button("Copy") {
            viewModel.copyContents()
          }
        }
      }
  }
}

struct MessagesView: View {
  @ObservedObject var viewModel: MessagesViewModel

  @State private var bannerHeight = Double(0)
  @State private var lastMessageId: UUID?

  var body: some View {
    GeometryReader { geometry in
      ScrollViewReader { proxy in
        ScrollView(.vertical) {
          // Add space for banner overlay so it doesn't cover messages.
          Color.clear.frame(height: bannerHeight)
          LazyVStack {
            ForEach(viewModel.messages, id: \.id) { messageViewModel in
              MessageView(viewModel: messageViewModel, availableWidth: geometry.size.width)
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
    .background(Color(nsColor: .controlBackgroundColor))
    .overlay {
      if viewModel.isBuiltForDebug {
        VStack {
          DebugBuildBannerView()
            .background(
              GeometryReader { geometry in
                Color.clear.preference(key: BannerHeightKey.self, value: geometry.size.height)
              }
            )
          Spacer()
        }
      }
    }
    .onPreferenceChange(BannerHeightKey.self) { newHeight in
      bannerHeight = newHeight
    }
  }
}

fileprivate struct BannerHeightKey: PreferenceKey {
  static var defaultValue: CGFloat { 0 }
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value = value + nextValue()
  }
}
