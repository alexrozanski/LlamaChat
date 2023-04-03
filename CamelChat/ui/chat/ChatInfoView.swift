//
//  ChatInfoView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI

struct ChatInfoView: View {
  @Environment(\.openWindow) var openWindow

  @ObservedObject var viewModel: ChatInfoViewModel

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
      Section(content: {
        LabeledContent(content: {
          Text(viewModel.modelSize)
        }, label: {
          Text("Model Size")
        })
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
        Text("Model Stats")
          .font(.system(.body).smallCaps())
      })
    }
    .formStyle(.grouped)
    .frame(width: 300)
    .frame(maxHeight: 250)
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
