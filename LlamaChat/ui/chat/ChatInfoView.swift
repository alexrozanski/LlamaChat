//
//  ChatInfoView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI

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

  var body: some View {
    Form {
      Section {
        VStack {
          AvatarView(viewModel: viewModel.avatarViewModel, size: .large)
            .padding(.bottom, 8)
          VStack(spacing: 4) {
            Text(viewModel.name)
              .font(.headline)
            Text(viewModel.modelType)
              .font(.system(size: 12))
          }
        }
        .frame(maxWidth: .infinity)
      }
      Section {
        HStack(spacing: 16) {
          ActionButton(title: "clear", imageName: "trash.circle.fill", enabledTextColor: .red, handler: {
            showClearMessagesAlert = true
          })
          .disabled(!viewModel.canClearMessages)
          ActionButton(title: "info", imageName: "info.circle.fill", enabledTextColor: .blue, handler: {
            SettingsWindowPresenter.shared.present(deeplinkingTo: .sources(sourceId: viewModel.sourceId))
          })
        }
        .frame(maxWidth: .infinity, alignment: .center)
      }
      Section {
        LabeledContent(content: {
          Text(viewModel.modelSize)
        }, label: {
          Text("Model Size")
        })
      }
      Section(content: {
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
      }, header: {
        Text("Model Parameters")
          .font(.system(.body).smallCaps())
      })
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
