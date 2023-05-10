//
//  SelectModelFormatView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import SwiftUI
import CardUI

struct SelectModelFormatView: View {
  @ObservedObject var viewModel: ConfigureLocalModelViewModel

  var body: some View {
    CardContentRowView(label: "Format", hasBottomBorder: true) {
      Picker("", selection: $viewModel.modelSourceType) {
        Text("Select Format")
          .foregroundColor(Color(nsColor: NSColor.disabledControlTextColor))
          .tag(ConfigureLocalModelSourceType?(nil))
        ForEach(ConfigureLocalModelSourceType.allCases) { source in
          Text(source.label).tag(ConfigureLocalModelSourceType?(source))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .multilineTextAlignment(.trailing)
        }
      }
      .fixedSize(horizontal: true, vertical: false)
    }
  }
}

fileprivate extension ConfigureLocalModelSourceType {
  var label: String {
    switch self {
    case .pyTorch: return "PyTorch Checkpoint (.pth)"
    case .ggml: return "GGML (.ggml)"
    }
  }
}
