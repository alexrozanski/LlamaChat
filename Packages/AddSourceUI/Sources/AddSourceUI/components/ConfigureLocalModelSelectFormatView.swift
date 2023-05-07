//
//  SelectFormatView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import SwiftUI

struct SelectFormatView: View {
  @ObservedObject var viewModel: ConfigureLocalModelSourceViewModel

  var body: some View {
    let sourceTypeBinding = Binding<ConfigureLocalModelSourceType?>(
      get: { viewModel.modelSourceType },
      set: { viewModel.select(modelSourceType: $0) }
    )
    Section {
      Picker("Format", selection: sourceTypeBinding) {
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
