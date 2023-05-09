//
//  SelectModelFormatView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import SwiftUI

struct SelectModelFormatView: View {
  @ObservedObject var viewModel: ConfigureLocalModelViewModel

  var body: some View {
    Section {
      Picker("Format", selection: $viewModel.modelSourceType) {
        Text("Select Format")
          .foregroundColor(Color(nsColor: NSColor.disabledControlTextColor))
          .tag(ConfigureLocalModelSourceType?(nil))
        ForEach(ConfigureLocalModelSourceType.allCases) { source in
          Text(source.label).tag(ConfigureLocalModelSourceType?(source))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .multilineTextAlignment(.trailing)
        }
      }
    } header: {
      VStack(alignment: .leading, spacing: 6) {
        Text("Model Settings")
        if let sourcingDescription = viewModel.modelSourcingDescription {
          Text(sourcingDescription)
            .font(.system(size: 12, weight: .regular))
        }
      }
      .padding(.bottom, 12)
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
