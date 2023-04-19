//
//  ButtonWithRandomSelector.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 19/04/2023.
//

import AppKit
import SwiftUI

struct NumericTextFieldWithRandomSelector: NSViewRepresentable {
  enum Value {
    case random
    case value(_ number: NSNumber)

    var isRandom: Bool {
      switch self {
      case .random: return true
      case .value: return false
      }
    }
  }

  let value: Binding<Value>
  let formatter: NumberFormatter

  func makeNSView(context: Context) -> TextFieldWithToggleButton {
    let textField = TextFieldWithToggleButton(
      value: value.wrappedValue,
      formatter: formatter,
      toggleButtonOffTitle: "Randomize",
      toggleButtonOnTitle: "Randomized",
      delegate: context.coordinator
    )
    return textField
  }

  func updateNSView(_ nsView: TextFieldWithToggleButton, context: Context) {
    nsView.value = value.wrappedValue
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }

  class Coordinator: NSObject, TextFieldWithToggleButtonDelegate {
    let parent: NumericTextFieldWithRandomSelector
    let formatter: NumberFormatter
    init(_ parent: NumericTextFieldWithRandomSelector) {
      self.parent = parent
      self.formatter = NumberFormatter()
    }

    func textFieldWithToggleButton(_ textFieldWithToggleButton: TextFieldWithToggleButton, didUpdateValue value: NumericTextFieldWithRandomSelector.Value) {
      parent.value.wrappedValue = value
    }
  }
}

// MARK: - TextFieldWithToggleButton

protocol TextFieldWithToggleButtonDelegate: AnyObject {
  func textFieldWithToggleButton(
    _ textFieldWithToggleButton: TextFieldWithToggleButton,
    didUpdateValue value: NumericTextFieldWithRandomSelector.Value
  )
}

class TextFieldWithToggleButton: NSView, NSTextFieldDelegate, ClickThroughDisabledTextFieldDelegate {
  private let toggleButton: ToggleButton
  private lazy var textField: ClickThroughDisabledTextField = {
    let textField = ClickThroughDisabledTextField()
    let cell = InsetTextFieldCell(textCell: "")
    cell.isBezeled = true
    cell.isEditable = true
    cell.isEnabled = true
    cell.isSelectable = true
    cell.bezelStyle = .roundedBezel
    textField.cell = cell
    textField.controlSize = .small
    textField.font = .systemFont(ofSize: 11)
    return textField
  }()

  var value: NumericTextFieldWithRandomSelector.Value {
    get {
      return _value
    }
    set {
      setValue(newValue, notifyDelegate: false)
    }
  }

  // Holds the actual _value value. Use setValue(_:notifyDelegate:) to set this and perform side-effects.
  private var _value: NumericTextFieldWithRandomSelector.Value

  private weak var delegate: TextFieldWithToggleButtonDelegate?
  private let formatter: NumberFormatter

  private let toggleButtonOffTitle: String
  private let toggleButtonOnTitle: String

  init(
    value: NumericTextFieldWithRandomSelector.Value,
    formatter: NumberFormatter,
    toggleButtonOffTitle: String,
    toggleButtonOnTitle: String,
    delegate: TextFieldWithToggleButtonDelegate
  ) {
    // Make sure this is initialized but call setValue(_:notifyDelegate:) later to ensure setup is done.
    _value = value

    self.formatter = formatter
    self.toggleButton = ToggleButton()
    self.toggleButtonOffTitle = toggleButtonOffTitle
    self.toggleButtonOnTitle = toggleButtonOnTitle
    self.delegate = delegate
    super.init(frame: .zero)

    addSubview(textField)
    textField.stringValue = "test"
    textField.delegate = self
    textField.clickThroughDelegate = self
    textField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalTo: topAnchor),
      textField.trailingAnchor.constraint(equalTo: trailingAnchor),
      textField.bottomAnchor.constraint(equalTo: bottomAnchor),
      textField.leadingAnchor.constraint(equalTo: leadingAnchor),
    ])

    addSubview(toggleButton)
    toggleButton.translatesAutoresizingMaskIntoConstraints = false
    toggleButton.target = self
    toggleButton.action = #selector(buttonAction(_:))

    NSLayoutConstraint.activate([
      toggleButton.topAnchor.constraint(equalTo: topAnchor, constant: 0.5),
      toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -0.5),
      toggleButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -0.5),
    ])

    setValue(value, notifyDelegate: false)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setValue(_ value: NumericTextFieldWithRandomSelector.Value, notifyDelegate: Bool) {
    self._value = value

    switch value {
    case .random:
      toggleButton.state = .on
      toggleButton.title = toggleButtonOnTitle
      textField.stringValue = "Value will be randomized"
      textField.isEnabled = false
    case .value(let number):
      toggleButton.state = .off
      toggleButton.title = toggleButtonOffTitle
      textField.stringValue = formatter.string(for: number) ?? ""
      textField.isEnabled = true
      textField.placeholderString = ""
    }

    if notifyDelegate {
      delegate?.textFieldWithToggleButton(self, didUpdateValue: _value)
    }
  }

  @objc func buttonAction(_ sender: ToggleButton) {
    if sender.state == .on {
      toggleButton.title = toggleButtonOnTitle
      setValue(.random, notifyDelegate: true)
    } else {
      toggleButton.title = toggleButtonOffTitle
      textField.stringValue = ""
      textField.isEnabled = true
      textField.becomeFirstResponder()
    }
  }

  // MARK: - NSTextFieldDelegate

  func controlTextDidEndEditing(_ obj: Notification) {
    if let number = formatter.number(from: textField.stringValue) {
      setValue(.value(number), notifyDelegate: true)
    } else {
      setValue(.random, notifyDelegate: true)
    }
  }

  // MARK: - ClickThroughDisabledTextFieldDelegate

  fileprivate func didClickThroughDisabledTextField(_ textField: ClickThroughDisabledTextField) {
    toggleButton.state = .off
  }
}

// MARK: - TextField

fileprivate class InsetTextFieldCell: NSTextFieldCell {
  override func drawingRect(forBounds rect: NSRect) -> NSRect {
    var rect = rect
    rect.size.width -= 50
    return super.drawingRect(forBounds: rect)
  }
}

fileprivate protocol ClickThroughDisabledTextFieldDelegate: AnyObject {
  func didClickThroughDisabledTextField(_ textField: ClickThroughDisabledTextField)
}

fileprivate class ClickThroughDisabledTextField: NSTextField {
  weak var clickThroughDelegate: ClickThroughDisabledTextFieldDelegate?

  override func mouseDown(with event: NSEvent) {
    if !isEnabled, let clickThroughDelegate {
      stringValue = ""
      isEnabled = true
      clickThroughDelegate.didClickThroughDisabledTextField(self)
      DispatchQueue.main.async { [weak self] in
        self?.becomeFirstResponder()
      }
    }
  }
}

// MARK: - Button

fileprivate class ToggleButtonCell: NSButtonCell {
  override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
    if isHighlighted {
      let path = NSBezierPath.bezierPathWithTrailingRoundedCorners(for: cellFrame.insetBy(dx: 0.5, dy: 0.5), in: controlView, cornerRadius: 5.5)
      NSColor.black.withAlphaComponent(0.05).set()
      path.fill()
    }

    NSColor.separatorColor.set()
    NSBezierPath(rect: NSRect(x: cellFrame.minX, y: cellFrame.minY + 0.5, width: 1, height: cellFrame.height - 1)).fill()

    drawTitle(attributedTitle, withFrame: cellFrame, in: controlView)
  }

  override func cellSize(forBounds rect: NSRect) -> NSSize {
    var size = super.cellSize(forBounds: rect)
    size.width += 10
    return size
  }
}

class ToggleButton: NSButton {
  init() {
    super.init(frame: .zero)
    let cell = ToggleButtonCell(textCell: "")
    cell.isBezeled = false
    cell.isBordered = false
    cell.setButtonType(.toggle)
    self.cell = cell
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Drawing

fileprivate extension NSBezierPath {
  static func bezierPathWithTrailingRoundedCorners(for rect: NSRect, in view: NSView, cornerRadius: CGFloat) -> NSBezierPath {
    let path = NSBezierPath()
    let scaledCornerRadius = cornerRadius * (view.window?.backingScaleFactor ?? 1.0)

    let bottomRightCorner = NSPoint(x: rect.maxX, y: rect.maxY)
    let topRightCorner = NSPoint(x: rect.maxX, y: rect.minY)
    path.move(to: NSPoint(x: rect.minX, y: rect.minY))
    path.line(to: NSPoint(x: rect.minX, y: rect.maxY))
    path.line(to: NSPoint(x: rect.maxX - scaledCornerRadius, y: rect.maxY))
    path.curve(to: NSPoint(x: rect.maxX, y: rect.maxY - scaledCornerRadius), controlPoint1: bottomRightCorner, controlPoint2: bottomRightCorner)
    path.line(to: NSPoint(x: rect.maxX, y: rect.minY + scaledCornerRadius))
    path.curve(to: NSPoint(x: rect.maxX - scaledCornerRadius, y: rect.minY), controlPoint1: topRightCorner, controlPoint2: topRightCorner)
    path.line(to: NSPoint(x: rect.minX, y: rect.minY))
    path.close()
    return path
  }
}
