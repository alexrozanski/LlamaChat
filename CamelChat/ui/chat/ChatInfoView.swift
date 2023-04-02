//
//  ChatInfoView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI

struct ChatInfoView: View {
  @ObservedObject var viewModel: ChatInfoViewModel

  var body: some View {
    VStack(spacing: 4) {
      Circle()
        .fill(.gray)
        .frame(width: 48, height: 48)
        .overlay {
          Text(String(viewModel.name.prefix(1)))
            .font(.system(size: 24))
            .foregroundColor(.white)
        }
        .padding(.bottom, 8)
      Text(viewModel.name)
        .font(.headline)
      Text(viewModel.modelType)
        .font(.system(size: 11))
    }
    .padding()
  }
}
