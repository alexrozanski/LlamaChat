//
//  SelectSourceTypeView.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI
import SharedUI
import DataModel

fileprivate struct Colors {
  static let border = Color(light: Color(hex: "#DEDEDE"), dark: Color(hex: "#FFFFFF", opacity: 0.2))
  static let hoverBackground = Color(light: .black.opacity(0.02), dark: .black.opacity(0.2))
}

typealias SelectHandler = (Model, ModelVariant) -> Void

struct SourceTypeVariantView: View {
  let variant: VariantViewModel
  let hasBottomBorder: Bool

  @State var hovered = false
  @State var infoPopoverPresented = false

  var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .firstTextBaseline) {
        Image(systemName: "point.3.connected.trianglepath.dotted")
        Text(variant.name)
          .fontWeight(.medium)
        if let description = variant.description {
          Button {
            infoPopoverPresented = true
          } label: {
            Image(systemName: "info.circle.fill")
              .foregroundColor(.gray)
          }
          .buttonStyle(.plain)
          .popover(isPresented: $infoPopoverPresented) {
            Text(description)
              .fixedSize(horizontal: false, vertical: true)
              .frame(width: 200)
              .padding()
          }
        }
        Spacer()
        Image(systemName: "chevron.right")
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 8)
      .background(
        hovered ? Colors.hoverBackground : .clear
      )
      .onHover { hovered in
        self.hovered = hovered
      }
      .onTapGesture {
        variant.select()
      }
      if hasBottomBorder {
        Rectangle()
          .fill(Colors.border)
          .frame(height: 0.5)
      }
    }
  }
}

struct SourceTypeView: View {
  @State var hovered = false

  let source: SourceViewModel
  let selectHandler: SelectHandler

  @ViewBuilder var header: some View {
    VStack {
      HStack {
        Text(source.name)
          .fontWeight(.semibold)
          .frame(maxWidth: .infinity, alignment: .leading)
        Spacer()
        if source.isRemote {
          SelectTypePillView(
            label: "Downloadable", style: .outlined(
              borderColor: Color(light: .init(hex: "#F9B9D8"), dark: .init(hex: "#FF2B91", opacity: 0.3)),
              textColor: Color(light: .init(hex: "#D33984"), dark: .init(hex: "#D33984"))
            )
          )
        }
        if !source.isRemote {
          ForEach(source.variants, id: \.id) { variant in
            SelectTypePillView(label: variant.name, style: .filled())
          }
        }
        SelectTypePillView(label: "English", iconName: "globe.desk")
      }
      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text(source.description)
          Spacer()
          if source.isModelSelectable {
            Image(systemName: "chevron.right")
          }
        }
        Text(source.publisher)
          .foregroundColor(.gray)
          .font(.footnote)
      }
    }
  }

  @ViewBuilder var selectableSources: some View {
    VStack(spacing: 0) {
      ForEach(source.variants, id: \.id) { variant in
        SourceTypeVariantView(variant: variant, hasBottomBorder: variant.id != source.variants.last?.id)
      }
    }
  }

  var body: some View {
    return VStack(spacing: 0) {
      header
        .padding(12)
      if source.hasSelectableVariants {
        Rectangle()
          .fill(Colors.border)
          .frame(height: 0.5)
        selectableSources
      }
    }
    .background(
      RoundedRectangle(cornerRadius: 4)
        .stroke(Colors.border, lineWidth: 1)
    )
    .background(
      Color(light: .white, dark: .clear)
        .overlay {
          if hovered {
            Colors.hoverBackground
          }
        }
    )
    .cornerRadius(4)
    .onHover { hovered in
      if source.isModelSelectable {
        self.hovered = hovered
      }
    }
    .onTapGesture {
      source.select()
    }
  }
}

struct CenteredContent<Content>: View where Content: View {
  typealias ContentBuilder = () -> Content

  private let contentBuilder: ContentBuilder
  init(contentBuilder: @escaping ContentBuilder) {
    self.contentBuilder = contentBuilder
  }

  var body: some View {
    VStack {
      Spacer()
      contentBuilder()
      Spacer()
    }
  }
}

struct SelectSourceTypeView: View {
  @ObservedObject var viewModel: SelectSourceTypeViewModel

  @State private var contentHeight: CGFloat = 0
  @State private var scrollViewOffset: CGFloat = 0
  @State private var showTopContentSeparator = false

  @ViewBuilder var content: some View {
    switch viewModel.content {
    case .none:
      EmptyView()
    case .loading:
      CenteredContent {
        DebouncedView {
          ProgressView()
            .progressViewStyle(.circular)
            .controlSize(.small)
        }
      }
    case .emptyFilter:
      CenteredContent {
        Text("No sources match your current filters")
          .foregroundColor(.gray)
      }
    case .sources:
      ScrollView {
        VStack {
          ForEach(viewModel.sources, id: \.id) { source in
            SourceTypeView(source: source) { model, variant in
              viewModel.selectModel(model, variant: variant)
            }
          }
          GeometryReader { geometry in
            Color.clear
              .preference(
                key: ScrollViewOffsetPreferenceKey.self,
                value: geometry.frame(in: .named("scroll")).minY
              )
              .preference(
                key: ContentHeightPreferenceKey.self,
                value: geometry.frame(in: .named("content")).minY
              )
          }
        }
        .padding(.horizontal, 20)
        .coordinateSpace(name: "content")
      }
      .coordinateSpace(name: "scroll")
      .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
        scrollViewOffset = value
      }
      .onPreferenceChange(ContentHeightPreferenceKey.self) { value in
        contentHeight = value
      }
      .onChange(of: contentHeight) { newContentHeight in
        updateSeparatorVisibility(scrollViewOffset: scrollViewOffset, contentHeight: newContentHeight)
      }
      .onChange(of: scrollViewOffset) { newScrollViewOffset in
        updateSeparatorVisibility(scrollViewOffset: newScrollViewOffset, contentHeight: contentHeight)
      }
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      SelectSourceTypeFilterView(viewModel: viewModel.filterViewModel)
        .padding(20)
        .zIndex(10)
      Rectangle()
        .fill(.separator)
        .opacity(showTopContentSeparator ? 1 : 0)
        .frame(height: 1)
      content
        .zIndex(0)
    }
  }

  private func updateSeparatorVisibility(scrollViewOffset: CGFloat, contentHeight: CGFloat) {
    showTopContentSeparator = scrollViewOffset < contentHeight
  }
}

fileprivate struct ContentHeightPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat { 0 }
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value = nextValue()
  }
}

fileprivate struct ScrollViewOffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat { 0 }
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value = nextValue()
  }
}
