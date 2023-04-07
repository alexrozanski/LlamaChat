//
//  SourceTypeSelectionView.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI

struct SourceTypeSelectionRow: View {
  let source: SelectSourceTypeViewModel.Source
  let clickHandler: () -> Void

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
    .background(isHovered ? Color("GroupedSelectionRowHover") : .clear)
    .onHover { isHovered = $0 }
    .onTapGesture {
      clickHandler()
    }
  }
}

struct SourceTypeSelectionView: View {
  var viewModel: SelectSourceTypeViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(viewModel.sources, id: \.id) { source in
        SourceTypeSelectionRow(source: source, clickHandler: {
          viewModel.select(sourceType: source.type)
        })
        if source.id != viewModel.sources.last?.id {
          Divider()
        }
      }
    }
    .background(Color(nsColor: .systemGray).opacity(0.05))
    .mask(RoundedRectangle(cornerRadius: 4))
    .overlay(
      RoundedRectangle(cornerRadius: 4)
        .stroke(Color(nsColor: .separatorColor))
    )
  }
}
