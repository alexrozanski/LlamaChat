//
//  SourceTypeSelectionView.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI

struct SourceTypeSelectionRow: View {
  let source: SourceTypeSelectionViewModel.Source

  @State var isHovered = false

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(source.name)
          .fontWeight(.bold)
        Text(source.description)
      }
      .padding()
      Spacer()
      Image(systemName: "chevron.right")
        .padding(.trailing)
    }
    .background(isHovered ? Color("SourceTypeSelectionRowHover") : .clear)
    .onHover { isHovered = $0 }
  }
}

struct SourceTypeSelectionView: View {
  var viewModel: SourceTypeSelectionViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(viewModel.sources, id: \.id) { source in
        SourceTypeSelectionRow(source: source)
        if source.id != viewModel.sources.last?.id {
          Divider()
        }
      }
    }
    .mask(RoundedRectangle(cornerRadius: 4))
    .background(Color(cgColor: NSColor.systemGray.withAlphaComponent(0.05).cgColor))
    .overlay(
      RoundedRectangle(cornerRadius: 4)
        .stroke(Color(cgColor: NSColor.separatorColor.cgColor))
    )
  }
}
