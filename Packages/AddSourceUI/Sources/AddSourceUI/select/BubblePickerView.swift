//
//  BubblePickerView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 05/05/2023.
//

import SwiftUI
import SharedUI

struct EventMonitorView: NSViewRepresentable {
  let active: Bool
  let onClickedOutside: () -> Void

  func makeNSView(context: Context) -> some NSView {
    let view = NSView()
    context.coordinator.updateMonitor(isActive: active)
    context.coordinator.view = view
    return view
  }

  func updateNSView(_ nsView: NSViewType, context: Context) {
    context.coordinator.updateMonitor(isActive: active)
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }

  class Coordinator {
    var parent: EventMonitorView
    weak var view: NSView?

    var eventMonitor: Any? {
      didSet {
        if let oldValue {
          NSEvent.removeMonitor(oldValue)
        }
      }
    }

    init(_ parent: EventMonitorView) {
      self.parent = parent
    }

    func updateMonitor(isActive: Bool) {
      if isActive {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown], handler: { [weak self] event in
          guard
            let self,
            let view = self.view,
            event.type == .leftMouseDown,
            event.window == view.window
          else { return event }

          let position = event.locationInWindow
          let viewFrame = view.convert(view.bounds, to: nil)

          if !viewFrame.contains(position) {
            self.parent.onClickedOutside()
          }
          return event
        })
      } else {
        eventMonitor = nil
      }
    }
  }
}

fileprivate struct ItemButtonStyle: ButtonStyle {
  let hovered: Bool
  let selected: Bool

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(EdgeInsets(top: 4, leading: 12, bottom: 6, trailing: selected ? 8 : 20))
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(hovered ? Color(light: .init(hex: "#EEEEEE"), dark: .init(hex: "#FFFFFF", opacity: 0.1)) : .clear)
  }
}

fileprivate struct ItemView<Value>: View where Value: Equatable, Value: Hashable {
  @State var hovered = false

  let item: BubblePickerView<Value>.Item
  let selected: Bool
  let onSelect: () -> Void

  var body: some View {
    Button {
      onSelect()
    } label: {
      HStack {
        Text(item.label)
          .fixedSize(horizontal: true, vertical: false)
        Spacer()
        if selected {
          Image(systemName: "checkmark")
            .font(.system(size: 10, weight: .bold))
        }
      }
    }
    .buttonStyle(ItemButtonStyle(hovered: hovered, selected: selected))
    .focusable(false)
    .onHover { hovered in
      self.hovered = hovered
    }
  }
}

fileprivate struct ItemsBackgroundShape: Shape {
  let bubbleHeight: Double
  let cornerRadius: Double
  init(bubbleHeight: Double, cornerRadius: Double) {
    self.bubbleHeight = bubbleHeight
    self.cornerRadius = cornerRadius
  }

  func path(in rect: CGRect) -> Path {
    var background = Path(
      // Offset the y value to make use of the nonzero winding rule to cut the bubble out of the path
      NSBezierPath(
        roundedRect: CGRect(x: 0, y: cornerRadius, width: rect.width, height: rect.height - cornerRadius),
        corners: [.bottomLeft, .bottomRight], cornerRadius: cornerRadius
      )
    )
    background.addPath(
      Path(
        roundedRect: CGRect(x: 0, y: 0, width: rect.width, height: bubbleHeight),
        cornerRadius: cornerRadius
      )
    )
    return background
  }
}

fileprivate struct ItemsView<Value>: View where Value: Equatable, Value: Hashable {
  let items: [BubblePickerView<Value>.Item]
  let selectedValue: Value?
  let topMargin: CGFloat
  let width: CGFloat?
  let bubbleHeight: Double
  let cornerRadius: Double
  let onSelectItem: (BubblePickerView<Value>.Item) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(items, id: \.value) { item in
        ItemView(
          item: item,
          selected: item.value == selectedValue,
          onSelect: {
            onSelectItem(item)
          }
        )
        .frame(width: width)
      }
    }
    .padding(.top, topMargin)
    .fixedSize(horizontal: true, vertical: false)
    .background(
      Color(lightNsColor: .init(hex: "#F5F5F5"), darkNsColor: .windowBackgroundColor)
    )
    .clipShape(
      ItemsBackgroundShape(bubbleHeight: bubbleHeight, cornerRadius: cornerRadius)
    )
    .background(
      GeometryReader { geometry in
        Color.clear.preference(key: MaxViewWidthKey.self, value: geometry.size.width)
      }
    )
  }
}

// Doesn't handle frontmost z-indexing; must be positioned over all other views manually.
struct BubblePickerView<Value>: View where Value: Equatable, Value: Hashable {
  struct Item {
    let value: Value?
    let label: String
  }

  let label: String
  let items: [Item]
  let clearItemLabel: String
  let selection: Binding<Value?>

  @State var showingPopup = false
  @State var width: CGFloat?
  @State var height = Double(0)

  var title: String {
    guard
      let selectedValue = selection.wrappedValue,
      let selectedItem = items.first(where: { $0.value == selectedValue })
    else {
      return label
    }

    return selectedItem.label
  }

  var hasSelection: Bool {
    return selection.wrappedValue != nil
  }

  var body: some View {
    ZStack(alignment: .top) {
      HStack(spacing: 4) {
        Text(title)
          .foregroundColor(hasSelection ? .white : Color(light: .black, dark: .white))
          .frame(maxWidth: width != nil ? .infinity : nil, alignment: .leading)
        Image(systemName: "chevron.down")
          .font(.system(size: 10, weight: .bold))
          .foregroundColor(hasSelection ? .white : Color(light: .black, dark: .white))
      }
      .padding(EdgeInsets(top: 1, leading: 12, bottom: 3, trailing: 8))
      .frame(width: width)
      .background(
        RoundedRectangle(cornerRadius: height / 2)
          .fill(
            hasSelection
            ? Color(nsColor: NSColor.controlAccentColor)
            : Color(light: .init(hex: "#EEEEEE"), dark: .init(hex: "#FFFFFF", opacity: 0.3))
          )
      )
      .background(
        GeometryReader { geometry in
          Color.clear
            .preference(key: ViewHeightKey.self, value: geometry.size.height)
            .preference(key: MaxViewWidthKey.self, value: geometry.size.width)
        }
      )
      .onTapGesture {
        showingPopup.toggle()
      }
      .onPreferenceChange(ViewHeightKey.self) { newHeight in
        height = newHeight
      }
      .background(alignment: .top) {
        ItemsView(
          items: [Item(value: nil, label: clearItemLabel)] + items,
          selectedValue: selection.wrappedValue,
          topMargin: height + 4,
          width: width,
          bubbleHeight: height,
          cornerRadius: height / 2,
          onSelectItem: { item in
            selection.wrappedValue = item.value
            showingPopup = false
          }
        )
        .frame(width: width)
        .opacity(showingPopup ? 1 : 0)
      }
    }
    .background(
      EventMonitorView(active: showingPopup) {
        showingPopup = false
      }
    )
    .onPreferenceChange(MaxViewWidthKey.self) { newWidth in
      width = newWidth
    }
  }
}

fileprivate struct ViewHeightKey: PreferenceKey {
  static var defaultValue = Double(0)
  static func reduce(value: inout Double, nextValue: () -> Double) {
    value = nextValue()
  }
}

fileprivate struct MaxViewWidthKey: PreferenceKey {
  static var defaultValue = Double(0)
  static func reduce(value: inout Double, nextValue: () -> Double) {
    value = max(value, nextValue())
  }
}
