//
//  ConvertSourceStepView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 13/04/2023.
//

import SwiftUI
import SharedUI

fileprivate struct RunTimeLabel: View {
  @ObservedObject var viewModel: ConvertSourceStepViewModel

  @ViewBuilder var label: some View {
    if let runTime = viewModel.runTime {
      switch viewModel.state {
      case .notStarted, .skipped, .cancelled:
        EmptyView()
      case .running:
        Text("Running for \(String(format: "%.1f", floor(runTime))) seconds...")
          .font(.footnote)
          .padding(.horizontal, 14)
          .padding(.vertical, 8)
      case .finished:
        Text("Finished in \(String(format: "%.1f", runTime)) seconds")
          .font(.footnote)
          .padding(.horizontal, 14)
          .padding(.vertical, 8)
      }
    }
  }

  var body: some View {
    label
  }
}

fileprivate struct DetailView: View {
  @ObservedObject var viewModel: ConvertSourceStepViewModel

  var body: some View {
    VStack(spacing: 0) {
      NonEditableTextView(viewModel: viewModel.textViewModel, scrollBehavior: .pinToBottom)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
      Rectangle()
        .fill(Color(nsColor: .separatorColor))
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 0.5)
        .frame(height: 1)
      HStack(spacing: 0) {
        RunTimeLabel(viewModel: viewModel)
        Spacer()
        Rectangle()
          .fill(Color(nsColor: .separatorColor))
          .frame(maxHeight: .infinity)
          .padding(.vertical, 0.5)
          .frame(width: 1)
        Text("Exit Code: `\(viewModel.exitCode.map { String($0) } ?? "-")`")
          .font(.footnote)
          .padding(.horizontal, 14)
          .padding(.vertical, 8)
      }
    }
    .background(Color(nsColor: .controlBackgroundColor))
    .mask(RoundedRectangle(cornerRadius: 4))
    .overlay(
      RoundedRectangle(cornerRadius: 4)
        .stroke(Color(nsColor: .separatorColor))
    )
  }
}

struct ConvertSourceStepView: View {
  @ObservedObject var viewModel: ConvertSourceStepViewModel

  var body: some View {
    VStack {
      LabeledContent(content: {
        switch viewModel.state {
        case .notStarted:
          EmptyView()
        case .skipped:
          Image(systemName: "exclamationmark.octagon")
            .foregroundColor(.gray)
        case .running:
          ProgressView()
            .progressViewStyle(.circular)
            .controlSize(.small)
        case .cancelled:
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.red)
        case .finished(result: let result):
          switch result {
          case .success(let exitCode):
            if exitCode == 0 {
              Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            } else {
              Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
            }
          case .failure:
            Image(systemName: "xmark.circle.fill")
              .foregroundColor(.red)
          }
        }
      }, label: {
        HStack(spacing: 4) {
          Button(action: {
            viewModel.toggleExpansion()
          }, label: {
            Image(systemName: viewModel.expanded ? "arrowtriangle.down.fill" : "arrowtriangle.forward.fill")
              .resizable()
              .scaledToFit()
              .foregroundColor(.gray)
              .frame(width: 8, height: 8)
              .padding(.trailing, 4)
          })
          .buttonStyle(.borderless)
          Text(viewModel.label)
        }
      })
      if viewModel.expanded {
        DetailView(viewModel: viewModel)
      }
    }
  }
}
