//
//  BubblePickerView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 05/05/2023.
//

import SwiftUI
import SharedUI

struct ChevronShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let width = rect.size.width
    let height = rect.size.height
    path.move(to: CGPoint(x: 0.76311*width, y: 0.36279*height))
    path.addCurve(to: CGPoint(x: 0.70418*width, y: 0.36279*height), control1: CGPoint(x: 0.74684*width, y: 0.34652*height), control2: CGPoint(x: 0.72046*width, y: 0.34652*height))
    path.addLine(to: CGPoint(x: 0.47851*width, y: 0.58847*height))
    path.addLine(to: CGPoint(x: 0.25284*width, y: 0.36279*height))
    path.addCurve(to: CGPoint(x: 0.19391*width, y: 0.36279*height), control1: CGPoint(x: 0.23656*width, y: 0.34652*height), control2: CGPoint(x: 0.21018*width, y: 0.34652*height))
    path.addCurve(to: CGPoint(x: 0.19391*width, y: 0.42172*height), control1: CGPoint(x: 0.17764*width, y: 0.37907*height), control2: CGPoint(x: 0.17764*width, y: 0.40545*height))
    path.addLine(to: CGPoint(x: 0.44835*width, y: 0.67616*height))
    path.addCurve(to: CGPoint(x: 0.47851*width, y: 0.68836*height), control1: CGPoint(x: 0.45666*width, y: 0.68447*height), control2: CGPoint(x: 0.46762*width, y: 0.68854*height))
    path.addCurve(to: CGPoint(x: 0.50867*width, y: 0.67616*height), control1: CGPoint(x: 0.48941*width, y: 0.68854*height), control2: CGPoint(x: 0.50036*width, y: 0.68447*height))
    path.addLine(to: CGPoint(x: 0.76311*width, y: 0.42172*height))
    path.addCurve(to: CGPoint(x: 0.76311*width, y: 0.36279*height), control1: CGPoint(x: 0.77938*width, y: 0.40545*height), control2: CGPoint(x: 0.77938*width, y: 0.37907*height))
    path.closeSubpath()
    return path
  }
}

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
      .background(hovered ? Color(light: .init(hex: "#EEEEEE"), dark: .init(hex: "#EEEEEE")) : .clear)
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

fileprivate struct ItemsView<Value>: View where Value: Equatable, Value: Hashable {
  let items: [BubblePickerView<Value>.Item]
  let selectedValue: Value?
  let topMargin: CGFloat
  let width: CGFloat?
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
      Color(light: .init(hex: "#F5F5F5"), dark: .init(hex: "#F5F5F5"))
    )
    .clipShape(
      RoundedRectangleWithCorners(radius: cornerRadius, corners: [.bottomLeft, .bottomRight])
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
          .foregroundColor(hasSelection ? .white : .black)
          .frame(maxWidth: width != nil ? .infinity : nil, alignment: .leading)
        ChevronShape()
          .frame(width: 12, height: 12)
          .foregroundColor(hasSelection ? .white : .black)
      }
      .padding(EdgeInsets(top: 1, leading: 12, bottom: 3, trailing: 8))
      .frame(width: width)
      .background(
        RoundedRectangle(cornerRadius: height / 2)
          .fill(
            hasSelection
            ? Color(nsColor: NSColor.controlAccentColor)
            : Color(light: .init(hex: "#EEEEEE"), dark: .init(hex: "#EEEEEE"))
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
          topMargin: height / 2 + 4,
          width: width,
          cornerRadius: height / 2,
          onSelectItem: { item in
            selection.wrappedValue = item.value
            showingPopup = false
          }
        )
        .frame(width: width)
        .offset(y: height / 2)
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
