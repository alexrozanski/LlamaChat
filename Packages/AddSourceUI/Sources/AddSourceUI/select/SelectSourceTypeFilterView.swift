//
//  SelectSourceTypeFilterView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 04/05/2023.
//

import SwiftUI

struct SelectSourceTypeFilterView: View {
  @ObservedObject var viewModel: SelectSourceTypeFilterViewModel

  var body: some View {
    HStack {
      Text("Filter")
        .fontWeight(.semibold)
      BubblePickerView(label: "Location", items: [
        BubblePickerView.Item(id: "local", label: "Bring Your Own"),
        BubblePickerView.Item(id: "remote", label: "Downloadable")
      ], clearItemLabel: "All Locations", selection: $viewModel.location)
      BubblePickerView(label: "Languages", items: [
        BubblePickerView.Item(id: "en", label: "English")
      ], clearItemLabel: "All Languages", selection: $viewModel.languages)
      if viewModel.hasFilters {
        Button {
          viewModel.resetFilters()
        } label: {
          Text("Reset")
        }
      }

      Spacer()
    }
  }
}
