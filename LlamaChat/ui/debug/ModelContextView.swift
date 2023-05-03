//
//  ModelContextView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import SwiftUI
import AppModel
import DataModel

private let tokenTextAttributes: [NSAttributedString.Key: Any] = [
  .font: NSFont.systemFont(ofSize: 12),
  .foregroundColor: NSColor.white
]

fileprivate extension ChatModel.ChatContext.Token {
  var displayableString: String {
    if string == "" {
      return "\"\""
    }
    if string == " " {
      return "\" \""
    }

    var displayableString = string
    displayableString = displayableString.replacingOccurrences(of: "\n", with: "\\n")
    displayableString = displayableString.replacingOccurrences(of: "\t", with: "\\t")
    return displayableString
  }
}

class TokenAttachmentCell: NSTextAttachmentCell {
  let text: String

  private static let horizontalPadding = Double(4)
  private static let verticalPadding = Double(2)

  private lazy var textSize: CGSize = {
    return text.size(withAttributes: tokenTextAttributes)
  }()


  private func cellRect(for position: NSPoint) -> NSRect {
    let cellSize = CGSize(width: textSize.width + 10, height: textSize.height + 2)
    return NSRect(x: position.x, y: position.y - cellSize.height, width: cellSize.width, height: cellSize.height)
  }

  init(token: Int32) {
    self.text = "\(token)"
    super.init(textCell: text)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
    var backgroundRect = cellRect(for: NSPoint(x: cellFrame.origin.x, y: cellFrame.maxY))
    backgroundRect.origin.x += TokenAttachmentCell.horizontalPadding
    backgroundRect.origin.y -= TokenAttachmentCell.verticalPadding

    let backgroundPath = NSBezierPath(roundedRect: backgroundRect, xRadius: 4, yRadius: 4)
    NSColor.controlAccentColor.set()
    backgroundPath.fill()

    let textRect = NSRect(x: cellFrame.origin.x + (cellFrame.size.width - textSize.width) / 2,
                          y: cellFrame.origin.y + (cellFrame.size.height - textSize.height) / 2,
                          width: textSize.width, height: textSize.height)
    text.draw(in: textRect, withAttributes: tokenTextAttributes)
  }

  override func cellFrame(for textContainer: NSTextContainer, proposedLineFragment lineFrag: NSRect, glyphPosition position: NSPoint, characterIndex charIndex: Int) -> NSRect {
    var cellRect = cellRect(for: position)
    cellRect.size.height += 2 * TokenAttachmentCell.verticalPadding
    cellRect.size.width += 2 * TokenAttachmentCell.horizontalPadding
    return cellRect
  }
}

struct ModelContextTokenView: NSViewRepresentable {
  var tokens: [ChatModel.ChatContext.Token]

  enum Style {
    case tokensOnly
    case tokensAndText

    var includesTokenText: Bool {
      switch self {
      case .tokensOnly:
        return false
      case .tokensAndText:
        return true
      }
    }
  }

  var style: Style

  func makeNSView(context: Context) -> NSScrollView {
    let scrollView = NSTextView.scrollableTextView()
    guard let textView = scrollView.documentView as? NSTextView else {
      return scrollView
    }
    scrollView.documentView = textView
    textView.isEditable = false
    textView.textContainerInset = NSSize(width: 8, height: 8)
    textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)

    updateTextView(textView, with: tokens, style: style)

    return scrollView
  }

  func updateNSView(_ nsView: NSScrollView, context: Context) {
    if let textView = nsView.documentView as? NSTextView {
      updateTextView(textView, with: tokens, style: style)
    }
  }
}

private func updateTextView(_ textView: NSTextView, with tokens: [ChatModel.ChatContext.Token], style: ModelContextTokenView.Style) {
  let newString = NSMutableAttributedString()
  tokens.forEach { token in
    if style.includesTokenText {
      newString.append(NSAttributedString(string: token.displayableString, attributes: [.font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)]))
    }

    let attachment = NSTextAttachment()
    attachment.attachmentCell = TokenAttachmentCell(token: token.value)

    newString.append(NSAttributedString(attachment: attachment))
    newString.append(NSAttributedString(string: " "))
  }
  textView.textStorage?.setAttributedString(newString)
}

struct ModelContextView: View {
  var chatSourceId: ChatSource.ID?

  @EnvironmentObject var dependencies: Dependencies

  @StateObject var viewModel: ModelContextContentViewModel

  init(chatSourceId: ChatSource.ID? = nil) {
    self.chatSourceId = chatSourceId
    _viewModel = StateObject(wrappedValue: ModelContextContentViewModel(chatSourceId: chatSourceId))
  }

  var body: some View {
    VStack {
      ModelContextContentView(viewModel: viewModel)
        .onAppear {
          viewModel.chatSourcesModel = dependencies.chatSourcesModel
          viewModel.chatModels = dependencies.chatModels
        }
    }
  }
}

struct EmptyContentView: View {
  let label: String

  var body: some View {
    Color.white
      .overlay(
        Text(label)
          .foregroundColor(.gray)
      )
  }
}

struct ModelContextContentView: View {
  @ObservedObject var viewModel: ModelContextContentViewModel

  @ViewBuilder var controls: some View {
    let presentationBinding = Binding(
      get: { viewModel.contextPresentation },
      set: { viewModel.updateContextPresentation($0) }
    )
    HStack {
      Picker("Show: ", selection: presentationBinding) {
        Text("Text").tag(ModelContextContentViewModel.ContextPresentation.text)
        Text("Tokens").tag(ModelContextContentViewModel.ContextPresentation.tokens)
        Divider()
        Text("Both").tag(ModelContextContentViewModel.ContextPresentation.both)
      }
      .disabled(!viewModel.hasSource || viewModel.context.isEmpty)
      .fixedSize()
      Spacer()
    }
  }

  @ViewBuilder var content: some View {
    switch viewModel.context {
    case .empty:
      EmptyContentView(label: "Empty Context")
    case .context(string: let string, tokens: let tokens):
      switch viewModel.contextPresentation {
      case .text:
        NonEditableTextView(string: string, font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular))
      case .tokens:
        ModelContextTokenView(tokens: tokens, style: .tokensOnly)
      case .both:
        ModelContextTokenView(tokens: tokens, style: .tokensAndText)
      }
    }
  }

  var body: some View {
    VStack {
      controls
      if viewModel.hasSource {
        content
          .border(.separator)
      } else {
        EmptyContentView(label: "No source")
      }
    }
    .padding()
  }
}
