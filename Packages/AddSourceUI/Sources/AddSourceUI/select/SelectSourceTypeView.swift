//
//  SelectSourceTypeView.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI

struct SourceTypeView: View {
  @State var hovered = false

  let source: SelectSourceTypeViewModel.Source

  var body: some View {
    return HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(source.name)
          .frame(maxWidth: .infinity, alignment: .leading)
        Text(source.publisher)
          .foregroundColor(.gray)
          .font(.footnote)
      }
    }
    .padding()
    .background(
      Color(nsColor: .controlBackgroundColor)
        .overlay {
          if hovered {
            Color.black.opacity(0.02)
          }
        }
    )
    .cornerRadius(8)
    .shadow(color: .black.opacity(0.1), radius: 2)
    .onHover { hovered in
      self.hovered = hovered
    }
  }
}

struct SelectSourceTypeView: View {
  @ObservedObject var viewModel: SelectSourceTypeViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      SelectSourceTypeFilterView()
        .zIndex(10)
      ForEach(viewModel.sources, id: \.name) { source in
        SourceTypeView(source: source)
      }
      .zIndex(0)
    }
  }
}
