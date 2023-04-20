//
//  MessagesView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct MessagesView: View {
  @ObservedObject var viewModel: MessagesViewModel

  @State private var bannerHeight = Double(0)

  var body: some View {
    MessagesTableView(messages: viewModel.messages)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .overlay {
        if viewModel.isBuiltForDebug {
          VStack {
            DebugBuildBannerView()
              .background(
                GeometryReader { geometry in
                  Color.clear.preference(key: BannerHeightKey.self, value: geometry.size.height)
                }
              )
            Spacer()
          }
        }
      }
      .onPreferenceChange(BannerHeightKey.self) { newHeight in
        bannerHeight = newHeight
      }
  }
}

fileprivate struct BannerHeightKey: PreferenceKey {
  static var defaultValue: CGFloat { 0 }
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value = value + nextValue()
  }
}
