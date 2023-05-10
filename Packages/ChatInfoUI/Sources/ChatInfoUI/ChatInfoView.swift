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

public struct ChatInfoView<ParametersContent>: View where ParametersContent: View {
  public typealias ParametersContentBuilder = () -> ParametersContent

  @ObservedObject public var viewModel: ChatInfoViewModel

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

  let parametersContentBuilder: ParametersContentBuilder

  public init(
    viewModel: ChatInfoViewModel,
    @ViewBuilder parametersContent: @escaping ParametersContentBuilder
  ) {
    self.viewModel = viewModel
    self.parametersContentBuilder = parametersContent
  }

  public var body: some View {
    Form {
      header
      actions
      properties
      parametersContentBuilder()
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
  }
}
