//
//  GeneralSettingsView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 15/04/2023.
//

import SwiftUI

struct GeneralSettingsView: View {
  @ObservedObject var viewModel: GeneralSettingsViewModel

  var body: some View {
    let selectedThreadCount = Binding(
      get: { viewModel.numThreads },
      set: { viewModel.numThreads = $0 }
    )
    VStack {
      Spacer()
      HStack {
        Spacer()
        HStack {
          Picker("Run prediction on:", selection: selectedThreadCount) {
            ForEach(viewModel.threadCountRange, id: \.self) { value in
              Text("\(value)")
                .tag(value)
            }
          }
          .fixedSize()
          Text("CPU threads")
        }
        Spacer()
      }
      Spacer()
    }
  }
}
