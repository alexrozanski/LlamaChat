//
//  ModelContextView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import SwiftUI

struct ModelContextTextView: NSViewRepresentable {
  let text: String

  func makeNSView(context: Context) -> NSScrollView {
    let scrollView = NSTextView.scrollableTextView()
    guard let textView = scrollView.documentView as? NSTextView else {
      return scrollView
    }
    scrollView.documentView = textView
    textView.string = text
    textView.isEditable = false
    textView.textContainerInset = NSSize(width: 8, height: 8)
    textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)

    return scrollView
  }

  func updateNSView(_ nsView: NSScrollView, context: Context) {
    if let textView = nsView.documentView as? NSTextView {
      textView.string = text
    }
  }
}

struct ModelContextView: View {
  var chatSourceId: ChatSource.ID?

  @EnvironmentObject var chatSources: ChatSources
  @EnvironmentObject var chatModels: ChatModels

  @StateObject var viewModel: ModelContextContentViewModel

  init(chatSourceId: ChatSource.ID? = nil) {
    self.chatSourceId = chatSourceId
    _viewModel = StateObject(wrappedValue: ModelContextContentViewModel(chatSourceId: chatSourceId))
  }

  var body: some View {
    VStack {
      ModelContextContentView(viewModel: viewModel)
        .onAppear {
          viewModel.chatSources = chatSources
          viewModel.chatModels = chatModels
        }
    }
  }
}

struct EmptyContentView: View {
  let label: String

  var body: some View {
    Color.white
      .border(.separator)
      .overlay(
        Text(label)
          .foregroundColor(.gray)
      )
  }
}

struct ModelContextContentView: View {
  @ObservedObject var viewModel: ModelContextContentViewModel

  @ViewBuilder var content: some View {
    if let context = viewModel.context {
      ModelContextTextView(text: context)
        .border(.separator)
    } else {
      EmptyContentView(label: "Empty Context")
    }
  }

  var body: some View {
    VStack {
      if viewModel.hasSource {
        content
          .padding()
      } else {
        EmptyContentView(label: "No source")
          .padding()
      }
    }
  }
}
