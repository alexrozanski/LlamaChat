//
//  LlamaFamilyModelParametersChatInfoView.swift
//  
//
//  Created by Alex Rozanski on 10/05/2023.
//

import SwiftUI
import ChatInfoUI
import SharedUI

public struct LlamaFamilyModelParametersChatInfoView: View {
  @Environment(\.openWindow) var openWindow

  @ObservedObject public var viewModel: LlamaFamilyModelParametersViewModel

  public init(viewModel: LlamaFamilyModelParametersViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    Section(content: {
      LabeledContent {
        Text(viewModel.seedValue.map { "\($0)" } ?? "Randomized")
      } label: {
        Text("Seed")
      }
      LabeledContent {
        Text("\(viewModel.contextSize) tokens")
      } label: {
        Text("Context Size")
      }
      LabeledContent(content: {
        VStack(alignment: .trailing) {
          modelStatText(modelStat: viewModel.contextTokenCount, unit: Unit(singular: "token", plural: "tokens"))
          if let value = viewModel.contextTokenCount.value, value > 0 {
            Button(action: {
              openWindow(id: WindowIdentifier.modelContext.rawValue, value: viewModel.sourceId)
            }, label: { Text("Show...") })
            .focusable(false)
          }
        }
      }, label: {
        Text("Current Context")
      })
      LabeledContent {
        Text("\(viewModel.numberOfTokens) tokens")
      } label: {
        Text("Max Response")
      }
    }, header: {
      HStack {
        Text("Model Parameters")
          .font(.system(.body).smallCaps())
        Spacer()
        Button("Configure...") {
          viewModel.configureParameters()
        }
        .font(.system(size: 11))
        .controlSize(.small)
      }
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
      LabeledContent {
        Text("\(viewModel.lastNTokensToPenalize)")
          .fontDesign(.monospaced)
      } label: {
        Text("Penalization Window")
      }
    }
    .onAppear {
      viewModel.loadModelStats()
    }
  }

  private func modelStatText<V>(
    modelStat: ModelStat<V>
  ) -> some View where V: CustomStringConvertible {
    switch modelStat {
    case .none:
      return Text("Empty")
    case .unknown:
      return Text("Unknown")
    case .loading:
      return Text("Loading")
    case .value(let value):
      return Text(value.description)
    }
  }

  private struct Unit {
    let singular: String
    let plural: String
  }

  private func modelStatText<V>(
    modelStat: ModelStat<V>,
    unit: Unit
  ) -> some View where V: Numeric {
    return modelStatText(modelStat: modelStat.map { value -> ModelStat<String> in
      if value == 0 {
        return .none
      } else if value == 1 {
        return .value("\(value) \(unit.singular)")
      } else {
        return .value("\(value) \(unit.plural)")
      }
    })
  }
}
