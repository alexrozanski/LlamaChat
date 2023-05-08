//
//  ConfirmDeleteSourceSheetContentView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI
import AppModel
import DataModel

public struct ConfirmDeleteSourceSheetContentView: View {
  public let viewModel: ConfirmDeleteSourceSheetViewModel
  public init(viewModel: ConfirmDeleteSourceSheetViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
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
