//
//  ConfigureLocalModelSourceView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

extension VerticalAlignment {
  private enum ModelPathField: AlignmentID {
    static func defaultValue(in dimension: ViewDimensions) -> CGFloat {
      return dimension[VerticalAlignment.center]
    }
  }

  static let modelPathField = VerticalAlignment(ModelPathField.self)
}

fileprivate struct ModelPathTextField: View {
  @ObservedObject var viewModel: ConfigureLocalModelSourceViewModel

  var body: some View {
    VStack(alignment: .trailing) {
      TextField("Model path", text: $viewModel.modelPath, prompt: Text("/path/to/model/file"))
        .textFieldStyle(.squareBorder)
        .alignmentGuide(.modelPathField, computeValue: { dimension in
          dimension[VerticalAlignment.center]
        })
      if viewModel.modelPathState == .invalid {
        HStack(spacing: 4) {
          Image(systemName: "exclamationmark.triangle")
            .foregroundColor(.red)
          Text("Model file not found at path")
            .foregroundColor(.red)
            .font(.footnote)
        }
      }
    }
  }
}

struct ConfigureLocalModelSourceView: View {
  @ObservedObject var viewModel: ConfigureLocalModelSourceViewModel
  var presentationStyle: AddSourceFlowPresentationStyle

  @ViewBuilder var pathSelector: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .modelPathField) {
        ModelPathTextField(viewModel: viewModel)
        Button(action: {
          let panel = NSOpenPanel()
          panel.allowsMultipleSelection = false
          panel.canChooseDirectories = false
          if panel.runModal() == .OK {
            viewModel.modelPath = panel.url?.path ?? ""
          }
        }, label: {
          Image(systemName: "ellipsis")
        })
      }
      Text("Select the quantized \(viewModel.modelType) model path. This should be called something like '\(viewModel.exampleModelPath)'")
        .font(.footnote)
        .padding(.top, 8)
    }
  }

  @ViewBuilder var settings: some View {
    let nameBinding = Binding(
      get: { viewModel.name },
      set: { viewModel.name = $0 }
    )
    TextField("Name", text: nameBinding)
      .textFieldStyle(.squareBorder)
    pathSelector
  }

  var body: some View {
    Form {
      if presentationStyle.showTitle {
        Section("Set up \(viewModel.modelType) model") {
          settings
        }
      } else {
        settings
      }
    }
    .formStyle(GroupedFormStyle())
  }
}
