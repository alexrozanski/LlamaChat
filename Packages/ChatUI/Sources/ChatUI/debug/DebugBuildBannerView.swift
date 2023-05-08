//
//  DebugBuildBannerView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 05/04/2023.
//

import SwiftUI

struct DebugBuildBannerView: View {
  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 4) {
      Image(systemName: "exclamationmark.circle")
        .fontWeight(.bold)
      Text("Interacting with the chat models in Debug builds is really slow. For optimal performance, rebuild for Release.")
      Spacer()
    }
    .padding(.vertical, 6)
    .padding(.horizontal, 8)
    .background(.red)
  }
}
