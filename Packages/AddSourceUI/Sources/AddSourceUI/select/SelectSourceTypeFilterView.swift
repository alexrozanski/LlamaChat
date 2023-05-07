//
//  SelectSourceTypeFilterView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 04/05/2023.
//

import SwiftUI

struct SearchField: View {
  var text: Binding<String>

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)
      TextField("Search", text: text)
        .onExitCommand {
          text.wrappedValue = ""
        }
        .textFieldStyle(.plain)
      if text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
        Button {
          text.wrappedValue = ""
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
        }
        .buttonStyle(.plain)
      }
    }
    .frame(height: 20)
    .padding(.horizontal, 4)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
    )
  }
}

struct SelectSourceTypeFilterView: View {
  @ObservedObject var viewModel: SelectSourceTypeFilterViewModel

  var body: some View {
    HStack {
      Text("Filter")
        .fontWeight(.semibold)
      BubblePickerView(label: "Model Source", items: [
        BubblePickerView.Item(value: SelectSourceTypeFilterViewModel.Location.local, label: "Bring Your Own"),
        BubblePickerView.Item(value: SelectSourceTypeFilterViewModel.Location.remote, label: "Downloadable")
      ], clearItemLabel: "All Sources", selection: $viewModel.location)
      BubblePickerView(label: "Languages", items: [
        BubblePickerView.Item(value: "en", label: "English")
      ], clearItemLabel: "All Languages", selection: $viewModel.languages)
      if viewModel.hasFilters {
        Button {
          viewModel.resetFilters()
        } label: {
          Text("Reset")
        }
      }
      Spacer()
      SearchField(text: $viewModel.searchFieldText)
        .frame(width: 150)
    }
  }
}
