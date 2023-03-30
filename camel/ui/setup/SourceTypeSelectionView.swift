//
//  SourceTypeSelectionView.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI

struct SourceTypeSelectionView: View {
  var viewModel: SourceTypeSelectionViewModel

  var body: some View {
    VStack(alignment: .leading) {
      ForEach(viewModel.sources, id: \.id) { source in
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
        if source.id != viewModel.sources.last?.id {
          Divider()
        }
      }
    }
    .background(
      RoundedRectangle(cornerRadius: 4)
        .fill(Color(cgColor: NSColor.systemGray.withAlphaComponent(0.05).cgColor))
        .overlay(
          RoundedRectangle(cornerRadius: 4)
            .stroke(Color(cgColor: NSColor.separatorColor.cgColor))
        )
    )
  }
}
