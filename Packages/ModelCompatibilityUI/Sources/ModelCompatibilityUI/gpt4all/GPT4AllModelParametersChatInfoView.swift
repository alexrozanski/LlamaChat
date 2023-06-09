//
//  GPT4AllModelParametersChatInfoView.swift
//  
//
//  Created by Alex Rozanski on 09/06/2023.
//

import SwiftUI
import ChatInfoUI
import SharedUI

public struct GPT4AllModelParametersChatInfoView: View {
  @ObservedObject public var viewModel: GPT4AllModelParametersViewModel

  public init(viewModel: GPT4AllModelParametersViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    Section(content: {
      LabeledContent {
        Text("\(viewModel.numberOfTokens) tokens")
      } label: {
        Text("Max Response")
      }
    }, header: {
      Text("Model Parameters")
        .font(.system(.body).smallCaps())
    })

    Section {
      LabeledContent {
        Text("\(viewModel.topP, specifier: "%.2f")")
          .fontDesign(.monospaced)
      } label: {
        Text("Top-p")
      }
      LabeledContent {
        Text("\(viewModel.topK)")
          .fontDesign(.monospaced)
      } label: {
        Text("Top-k")
      }
      LabeledContent {
        Text("\(viewModel.temperature, specifier: "%.2f")")
          .fontDesign(.monospaced)
      } label: {
        Text("Temperature")
      }
      LabeledContent {
        Text("\(viewModel.batchSize)")
          .fontDesign(.monospaced)
      } label: {
        Text("Batch Size")
      }
    }

    Section {
      LabeledContent {
        Text("\(viewModel.repeatPenalty, specifier: "%.2f")")
          .fontDesign(.monospaced)
      } label: {
        Text("Repeat Penalty")
      }
    }
  }
}
