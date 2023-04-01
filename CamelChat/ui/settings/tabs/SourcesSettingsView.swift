//
//  SourcesSettingsView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct SourcesListView: View {
  var viewModel: SourcesSettingsViewModel

  @State private var selectedSourceId: String?

  var body: some View {
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
      List(viewModel.sources, id: \.id, selection: $selectedSourceId) { source in
        Text(source.name)
      }
      .listStyle(PlainListStyle())
      // the selection background extends outside of the bounds of the List (presumably to cover its border)
      // but since we apply a border to the outside of this control separately, inset the list on the left and right.
      .padding(.horizontal, 1)
      HStack(spacing: 0) {
        Button(action: {}, label: {
          Image(systemName: "plus")
            .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 6))
        })
        .buttonStyle(BorderlessButtonStyle())
        Button(action: {}, label: {
          Image(systemName: "minus")
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 8))
        })
        .buttonStyle(BorderlessButtonStyle())
        Spacer()
      }
      .background(.white)
    }
    .border(.separator)
    .onAppear {
      selectedSourceId = viewModel.sources.first?.id
    }
  }
}

struct SourcesSettingsView: View {
  var viewModel: SourcesSettingsViewModel

  var body: some View {
    HStack {
      SourcesListView(viewModel: viewModel)
    }
    .padding()
  }
}
