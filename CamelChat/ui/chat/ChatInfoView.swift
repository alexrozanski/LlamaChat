//
//  ChatInfoView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI

struct ChatInfoView: View {
  @ObservedObject var viewModel: ChatInfoViewModel

  var body: some View {
    Form {
      Section {
        VStack {
          Circle()
            .fill(.gray)
            .frame(width: 48, height: 48)
            .overlay {
              Text(String(viewModel.name.prefix(1)))
                .font(.system(size: 24))
                .foregroundColor(.white)
            }
            .padding(.bottom, 8)
          Text(viewModel.name)
            .font(.headline)
          Text(viewModel.modelType)
            .font(.system(size: 11))
        }
        .frame(maxWidth: .infinity)
      }
      Section(content: {
        LabeledContent(content: {
          modelStatText(modelStat: viewModel.contextTokenCount, unit: Unit(singular: "token", plural: "tokens"))
        }, label: {
          Text("Context")
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
