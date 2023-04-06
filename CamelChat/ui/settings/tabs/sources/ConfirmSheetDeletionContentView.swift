//
//  ConfirmDeleteSourceSheetContentView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

class ConfirmDeleteSourceSheetViewModel: ObservableObject {
  let chatSource: ChatSource
  let chatSources: ChatSources
  private let closeHandler: () -> Void

  init(
    chatSource: ChatSource,
    chatSources: ChatSources,
    closeHandler: @escaping () -> Void
  ) {
    self.chatSource = chatSource
    self.chatSources = chatSources
    self.closeHandler = closeHandler
  }

  func cancel() {
    closeHandler()
  }

  func delete() {
    chatSources.remove(source: chatSource)
    closeHandler()
  }
}

struct ConfirmDeleteSourceSheetContentView: View {
  let viewModel: ConfirmDeleteSourceSheetViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Remove '\(viewModel.chatSource.name)'?")
        .font(.headline)
      Text("Are you sure you want to remove '\(viewModel.chatSource.name)' as a chat source? This cannot be undone.")
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
      HStack(spacing: 12) {
        Spacer()
        Button("Cancel") {
          viewModel.cancel()
        }
        Button("Remove") {
          viewModel.delete()
        }
      }
      .padding(.top, 16)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 28)
    .frame(maxWidth: 400)
    .fixedSize()
  }
}
