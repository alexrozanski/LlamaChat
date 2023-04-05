//
//  ConfigureLocalModelSourceView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

fileprivate extension VerticalAlignment {
  private enum LabelAlignment: AlignmentID {
    static func defaultValue(in dimension: ViewDimensions) -> CGFloat {
      return dimension[VerticalAlignment.center]
    }
  }

  static let label = VerticalAlignment(LabelAlignment.self)
}

fileprivate extension Alignment {
  static let label = Alignment(horizontal: .leading, vertical: .label)
}

private func errorText(for modelState: ConfigureLocalModelSourceViewModel.ModelState) -> String? {
  switch modelState {
  case .none, .valid:
    return nil
  case .invalidPath:
    return "Selected file is invalid"
  case .invalidModel(let reason):
    switch reason {
    case .unknown, .invalidFileType:
      return "Selected file is not a valid model"
    case .unsupportedModelVersion:
      return "Selected model is of an unsupported version"
    }
  }
}

struct ConfigureLocalModelSourceView: View {
  @ObservedObject var viewModel: ConfigureLocalModelSourceViewModel
  var presentationStyle: AddSourceFlowPresentationStyle

  @FocusState var isNameFocused: Bool

  @ViewBuilder var pathSelector: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .label) {
        LabeledContent {
          VStack(alignment: .trailing, spacing: 4) {
            Text(viewModel.modelPath ?? "No path selected")
              .lineLimit(1)
              .truncationMode(.head)
              .frame(maxWidth: 200, alignment: .trailing)
              .help(viewModel.modelPath ?? "")
            if let errorText = errorText(for: viewModel.modelState) {
              Text(errorText)
                .foregroundColor(.red)
                .font(.footnote)
            }
          }
        } label: {
          Text("Model path")
            .alignmentGuide(.label) { d in
              d[VerticalAlignment.firstTextBaseline]
            }
        }
        Button(action: {
          let panel = NSOpenPanel()
          panel.allowsMultipleSelection = false
          panel.canChooseDirectories = false
          if panel.runModal() == .OK {
            viewModel.modelPath = panel.url?.path ?? ""
          }
        }, label: {
          Text("Select...")
        })
        .alignmentGuide(.label) { d in
          d[VerticalAlignment.firstTextBaseline]
        }
      }
      Text("Select the quantized \(viewModel.modelType) model path. This should be called something like '\(viewModel.exampleModelPath)'")
        .font(.footnote)
        .padding(.top, 8)
    }
  }

  @State var selectedModelType: String = ""

  @ViewBuilder var nameGroup: some View {
    let nameBinding = Binding(
      get: { viewModel.name },
      set: { viewModel.name = $0 }
    )
    HStack {
      TextField("Name", text: nameBinding)
        .textFieldStyle(.squareBorder)
        .focused($isNameFocused)
      Button(action: {
        viewModel.generateName()
      }, label: { Image(systemName: "hands.sparkles.fill") })
    }
  }

  @ViewBuilder var modelGroup: some View {
    let modelTypeBinding = Binding(
      get: { viewModel.modelSize },
      set: { viewModel.modelSize = $0 }
    )
    pathSelector
    Picker("Model size", selection: modelTypeBinding) {
      Text("7B").tag(ModelSize.size7B)
      Text("12B").tag(ModelSize.size12B)
      Text("30B").tag(ModelSize.size30B)
      Text("65B").tag(ModelSize.size65B)
      Divider()
      Text("Unknown").tag(ModelSize.unknown)
    }
    .disabled(!viewModel.modelState.isValid)
  }

  var body: some View {
    Form {
      if presentationStyle.showTitle {
        Section("Set up \(viewModel.modelType) model") {
          nameGroup
        }
      } else {
        Section {
          nameGroup
        }
      }
      Section("Model Settings") {
        modelGroup
      }
    }
    .formStyle(GroupedFormStyle())
    .onAppear {
      isNameFocused = true
    }
  }
}
