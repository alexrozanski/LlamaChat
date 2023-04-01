//
//  SourcesSettingsListView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct SourcesSettingsListView: View {
  @ObservedObject var viewModel: SourcesSettingsViewModel

  @ViewBuilder var heading: some View {
    VStack(spacing: 0) {
      HStack {
        Text("Source")
          .font(.system(size: 11))
          .padding(.vertical, 8)
      }
      .frame(maxWidth: .infinity)
      .background(.white)
      Divider()
        .foregroundColor(Color(NSColor.separatorColor.cgColor))
    }
  }

  @ViewBuilder var actionButtons: some View {
    HStack(spacing: 0) {
      Button(action: { viewModel.showAddSourceSheet() }, label: {
        Image(systemName: "plus")
          .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 6))
      })
      .buttonStyle(BorderlessButtonStyle())
      Button(action: {
        guard let selectedSource = viewModel.sources.first(where: { $0 == viewModel.selectedSource }) else { return }
        viewModel.showConfirmDeleteSourceSheet(for: selectedSource)
      }, label: {
        Image(systemName: "minus")
          .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 8))
      })
      .disabled(viewModel.selectedSource == nil)
      .buttonStyle(BorderlessButtonStyle())
      Spacer()
    }
    .background(.white)
  }

  var body: some View {
    let selectionBinding = Binding<String?>(
      get: { viewModel.selectedSource?.id },
      set: { selectedId in viewModel.selectedSource = viewModel.sources.first(where: { $0.id == selectedId }) }
    )
    VStack(spacing: 0) {
      heading
      List(viewModel.sources, id: \.id, selection: selectionBinding) { source in
        Text(source.name)
      }
      .listStyle(PlainListStyle())
      // the selection background extends outside of the bounds of the List (presumably to cover its border)
      // but since we apply a border to the outside of this control separately, inset the list on the left and right.
      .padding(.horizontal, 1)
      actionButtons
    }
    .border(.separator)
    .onAppear {
      viewModel.selectedSource = viewModel.sources.first
    }
  }
}
