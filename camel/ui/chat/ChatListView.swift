//
//  ChatListView.swift
//  Camel
//
//  Created by Alex Rozanski on 28/03/2023.
//

import SwiftUI

struct ChatListView: View {
  @ObservedObject var viewModel: ChatSourcesViewModel

  var body: some View {
    ScrollView {
      VStack {
        ForEach(viewModel.sources, id: \.title) { source in
          Text(source.title)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
  }
}
