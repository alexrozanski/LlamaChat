//
//  SourcesSettingsView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct SourcesListView: View {
  @ObservedObject var viewModel: SourcesSettingsViewModel

  @State private var selectedSourceId: String?

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
        guard let selectedSource = viewModel.sources.first(where: { $0.id == selectedSourceId }) else { return }
        viewModel.showConfirmDeleteSourceSheet(for: selectedSource)
      }, label: {
        Image(systemName: "minus")
          .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 8))
      })
      .disabled(selectedSourceId == nil)
      .buttonStyle(BorderlessButtonStyle())
      Spacer()
    }
    .background(.white)
  }

  var body: some View {
    VStack(spacing: 0) {
      heading
      List(viewModel.sources, id: \.id, selection: $selectedSourceId) { source in
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
      selectedSourceId = viewModel.sources.first?.id
    }
  }
}

struct SourcesSettingsView: View {
  @ObservedObject var viewModel: SourcesSettingsViewModel  

  var body: some View {
    HStack {
      SourcesListView(viewModel: viewModel)
      .overlay {
        SheetPresentingView(viewModel: viewModel.activeSheetViewModel) { viewModel in
          if let viewModel = viewModel as? ConfirmDeleteSourceSheetViewModel {
            ConfirmDeleteSourceSheetContentView(viewModel: viewModel)
          } else if let viewModel = viewModel as? AddSourceSheetViewModel {
            AddSourceSheetContentView(viewModel: viewModel)
          }
        }
      }
    }
    .padding()
  }
}
