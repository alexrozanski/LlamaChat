//
//  NonEditableTextView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 08/04/2023.
//

import AppKit
import SwiftUI

public class NonEditableTextViewModel: ObservableObject {
  public typealias IsEmptyHandler = () -> Bool
  public typealias AppendHandler = (NSAttributedString) -> Void

  private(set) var _initialString: NSMutableAttributedString

  public enum State {
    case notConnected
    case connectedToTextView(isEmptyHandler: IsEmptyHandler, appendHandler: AppendHandler)
  }

  private var state: State = .notConnected

  public var isEmpty: Bool {
    switch state {
    case .notConnected:
      return _initialString.length == 0
    case .connectedToTextView(isEmptyHandler: let isEmpty, appendHandler: _):
      return isEmpty()
    }
  }

  public var initialString: NSAttributedString {
    return NSAttributedString(attributedString: _initialString)
  }

  public init(string: String? = nil, attributes: [NSAttributedString.Key: Any]? = nil) {
    _initialString = NSMutableAttributedString(string: string ?? "", attributes: attributes)
  }

  func disconnectFromTextView() {
    state = .notConnected
  }

  func connect(isEmptyHandler: @escaping IsEmptyHandler, appendHandler: @escaping AppendHandler) {
    state = .connectedToTextView(isEmptyHandler: isEmptyHandler, appendHandler: appendHandler)
  }

  public func append(attributedString: NSAttributedString) {
    switch state {
    case .notConnected:
      _initialString.append(attributedString)
    case .connectedToTextView(isEmptyHandler: _, appendHandler: let append):
      append(attributedString)
    }
  }
}

public struct NonEditableTextView: NSViewRepresentable {
  @ObservedObject public var viewModel: NonEditableTextViewModel

  public enum ScrollBehavior {
    case `default`
    case pinToBottom

    public var pinToBottom: Bool {
      switch self {
      case .default: return false
      case .pinToBottom: return true
      }
    }
  }

  public let scrollBehavior: ScrollBehavior

  public init(viewModel: NonEditableTextViewModel, scrollBehavior: ScrollBehavior = .default) {
    self.viewModel = viewModel
    self.scrollBehavior = scrollBehavior
  }

  public init(string: String, font: NSFont, scrollBehavior: ScrollBehavior = .default) {
    viewModel = NonEditableTextViewModel(string: string, attributes: [.font: font])
    self.scrollBehavior = scrollBehavior
  }

  public func makeNSView(context: Context) -> NSScrollView {
    let scrollView = NSTextView.scrollableTextView()
    guard let textView = scrollView.documentView as? NSTextView else {
      return scrollView
    }
    scrollView.documentView = textView

    textView.isEditable = false
    textView.textContainerInset = NSSize(width: 8, height: 8)

    context.coordinator.update(textView: textView, viewModel: viewModel)

    return scrollView
  }

  public func updateNSView(_ nsView: NSScrollView, context: Context) {
    if let textView = nsView.documentView as? NSTextView {
      context.coordinator.update(textView: textView, viewModel: viewModel)
    }
  }

  public class Coordinator {
    private var lastViewModel: NonEditableTextViewModel?

    let parent: NonEditableTextView
    init(_ parent: NonEditableTextView) {
      self.parent = parent
    }

    func update(textView: NSTextView, viewModel: NonEditableTextViewModel?) {
      guard let textStorage = textView.textStorage, let viewModel else { return }

      if viewModel !== lastViewModel {
        if let lastViewModel {
          lastViewModel.disconnectFromTextView()
        }

        viewModel.connect(isEmptyHandler: { [weak textStorage = textView.textStorage] in
          return textStorage?.length == 0
        }, appendHandler: { [weak self, weak textView, weak textStorage = textView.textStorage] attributedString in
          if let textView, textView.enclosingScrollView?.isScrolledToBottom() ?? false, self?.parent.scrollBehavior.pinToBottom ?? false {
            textView.scrollToEndOfDocument(nil)
          }
          textStorage?.append(attributedString)
        })

        textStorage.setAttributedString(viewModel.initialString)
        lastViewModel = viewModel
      }
    }
  }

  public func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
}
