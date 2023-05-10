//
//  ChatInfoView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI
import SharedUI

struct ActionButton: View {
  typealias Handler = () -> Void

  @Environment(\.isEnabled) private var isEnabled

  let title: String
  let imageName: String
  let enabledTextColor: Color
  let handler: Handler

  init(title: String, imageName: String, enabledTextColor: Color, handler: @escaping Handler) {
    self.title = title
    self.imageName = imageName
    self.enabledTextColor = enabledTextColor
    self.handler = handler
  }

  var body: some View {
    Button(action: handler) {
      VStack {
        Image(systemName: imageName)
          .symbolRenderingMode(isEnabled ? .multicolor : .monochrome)
          .resizable()
          .frame(width: 28, height: 28)
          .foregroundColor(isEnabled ? nil : .gray)
        Text(title)
          .foregroundColor(isEnabled ? enabledTextColor : .gray)
      }
    }
    .focusable(false)
    .buttonStyle(BorderlessButtonStyle())
  }
}

struct ChatInfoView: View {
  @Environment(\.openWindow) var openWindow

  @ObservedObject var viewModel: ChatInfoViewModel

  @State private var showClearMessagesAlert = false

  @ViewBuilder var header: some View {
    Section {
      VStack {
        AvatarView(viewModel: viewModel.avatarViewModel, size: .large)
          .padding(.bottom, 8)
        VStack(spacing: 4) {
          Text(viewModel.name)
            .font(.headline)
        }
      }
      .frame(maxWidth: .infinity)
    }
  }

  @ViewBuilder var actions: some View {
    Section {
      HStack(spacing: 16) {
        ActionButton(title: "clear", imageName: "trash.circle.fill", enabledTextColor: .red, handler: {
          showClearMessagesAlert = true
        })
        .disabled(!viewModel.canClearMessages)
        ActionButton(title: "info", imageName: "info.circle.fill", enabledTextColor: .blue, handler: {
          viewModel.showInfo()
        })
      }
      .frame(maxWidth: .infinity, alignment: .center)
    }
  }

  @ViewBuilder var properties: some View {
    Section {
      LabeledContent(content: {
        Text(viewModel.modelName)
      }, label: {
        Text("Model")
      })
      if let modelVariant = viewModel.modelVariant {
        LabeledContent(content: {
          Text(modelVariant)
        }, label: {
          Text("Model Variant")
        })
      }
    }
  }

  @ViewBuilder var parameters: some View {
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
  }

  var body: some View {
    Form {
      header
      actions
      properties
      parameters
    }
    .formStyle(.grouped)
    .frame(width: 280)
    .frame(maxHeight: 350)
    .alert(isPresented: $showClearMessagesAlert) {
      Alert(
        title: Text("Clear messages in chat?"),
        message: Text("This cannot be undone"),
        primaryButton: .destructive(Text("Clear"), action: { viewModel.clearMessages() }),
        secondaryButton: .cancel()
      )
    }
    .onAppear {
      viewModel.loadModelStats()
    }
  }

  private func modelStatText<V>(
    modelStat: ChatInfoViewModel.ModelStat<V>
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
    modelStat: ChatInfoViewModel.ModelStat<V>,
    unit: Unit
  ) -> some View where V: Numeric {
    return modelStatText(modelStat: modelStat.map { value -> ChatInfoViewModel.ModelStat<String> in
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
