//
//  ConfigureLocalModelPathSelectorView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 06/04/2023.
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

private func errorText(for modelState: ConfigureLocalModelState) -> String? {
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

struct ConfigureLocalModelPathSelectorView: View {
  @ObservedObject var viewModel: ConfigureLocalModelPathSelectorViewModel

  let useMultiplePathSelection: Bool
  let modelState: ConfigureLocalModelState

  @ViewBuilder var label: some View {
    Text(useMultiplePathSelection ? "Model Paths" : "Model Path")
      .alignmentGuide(.label) { d in
        d[VerticalAlignment.firstTextBaseline]
      }
  }

  @ViewBuilder var selectButton: some View {
    Button(action: {
      let panel = NSOpenPanel()
      panel.allowsMultipleSelection = useMultiplePathSelection
      panel.canChooseDirectories = false
      if panel.runModal() == .OK {
        viewModel.modelPaths = panel.urls.map { $0.path }
      }
    }, label: {
      Text("Select...")
    })
    .alignmentGuide(.label) { d in
      d[VerticalAlignment.firstTextBaseline]
    }
  }

  @ViewBuilder var singlePathSelectorContent: some View {
    HStack(alignment: .label) {
      LabeledContent {
        VStack(alignment: .trailing, spacing: 4) {
          Text(viewModel.modelPaths.first ?? "No path selected")
          .lineLimit(1)
          .truncationMode(.head)
          .frame(maxWidth: 200, alignment: .trailing)
          .help(viewModel.modelPaths.first ?? "")
          if let errorText = errorText(for: modelState) {
            Text(errorText)
              .foregroundColor(.red)
              .font(.footnote)
          }
        }
      } label: {
        label
      }
      selectButton
    }
  }

  @ViewBuilder var multiplePathSelectorContent: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .label) {
        LabeledContent {
          VStack(alignment: .trailing, spacing: 4) {
            Text(
              viewModel.modelPaths.isEmpty ? "No paths selected" : "\(viewModel.modelPaths.count) paths selected"
            )
            .frame(maxWidth: 200, alignment: .trailing)
            if let errorText = errorText(for: modelState) {
              Text(errorText)
                .foregroundColor(.red)
                .font(.footnote)
            }
          }
        } label: {
          label
        }
        selectButton
      }
      if !viewModel.modelPaths.isEmpty {
        VStack(alignment: .leading, spacing: 2) {
          ForEach(viewModel.modelPaths, id: \.self) { modelPath in
            Text(modelPath).foregroundColor(.gray)
          }
        }
        .padding(.top, 12)
      }
    }
  }

  var body: some View {
    if useMultiplePathSelection {
      multiplePathSelectorContent
    } else {
      singlePathSelectorContent
    }
  }
}
