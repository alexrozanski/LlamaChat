//
//  ConvertSourceView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 07/04/2023.
//

import SwiftUI

fileprivate struct RunTimeLabel: View {
  @ObservedObject var viewModel: ConvertSourceStepViewModel

  @ViewBuilder var label: some View {
    if let runTime = viewModel.runTime {
      switch viewModel.state {
      case .notStarted, .skipped:
        EmptyView()
      case .running:
        Text("Running for \(String(format: "%.1f", floor(runTime))) seconds...")
          .font(.footnote)
          .padding(.horizontal, 14)
          .padding(.vertical, 8)
      case .finished:
        Text("Finished in \(String(format: "%.1f", floor(runTime))) seconds")
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
        case .finished(result: let result):
          switch result {
          case .success:
            Image(systemName: "checkmark.circle.fill")
              .foregroundColor(.green)
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

struct ConvertSourceView: View {
  @ObservedObject var viewModel: ConvertSourceViewModel

  @ViewBuilder var startButton: some View {
    Button(action: {
      viewModel.startConversion()
    }) {
      Text("Start")
    }
  }

  var body: some View {
    VStack(alignment: .leading) {
      Form {
        switch viewModel.state {
        case .notStarted:
          Section {
            Text("CamelChat will convert the PyTorch model weights to the .ggml format.\n\nAdditional disk space is required since the original file(s) are left untouched.")
          }
        case .converting(let steps):
          makeConversionView(for: steps)
        }
      }
      .formStyle(.grouped)
      HStack {
        Spacer()
        if viewModel.state.isConverting {
          Button(action: {
            viewModel.stopConversion()
          }) {
            Text("Stop")
          }
        }
        Button(action: {
          viewModel.startConversion()
        }) {
          Text("Start")
        }
        .disabled(viewModel.state.isConverting)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
  }

  @ViewBuilder private func makeConversionView(for steps: [ConvertSourceStepViewModel]) -> some View {
    ForEach(steps, id: \.id) { stepViewModel in
      ConvertSourceStepView(viewModel: stepViewModel)
    }
  }
}
