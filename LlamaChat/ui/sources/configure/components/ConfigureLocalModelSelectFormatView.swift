//
//  ConfigureLocalModelSelectFormatView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import SwiftUI

struct ConfigureLocalModelSelectFormatView: View {
  @ObservedObject var viewModel: ConfigureLocalModelSourceViewModel

  var body: some View {
    let sourceTypeBinding = Binding<ConfigureLocalModelSourceType?>(
      get: { viewModel.modelSourceType },
      set: { viewModel.select(modelSourceType: $0) }
    )
    Section {
      Picker("Format", selection: sourceTypeBinding) {
        Text("Select Format")
          .foregroundColor(Color(NSColor.disabledControlTextColor.cgColor))
          .tag(ConfigureLocalModelSourceType?(nil))
        ForEach(ConfigureLocalModelSourceType.allCases) { source in
          Text(source.label).tag(ConfigureLocalModelSourceType?(source))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .multilineTextAlignment(.trailing)
        }
      }
    } header: {
      Text("Model Settings")
    }
  }
}
