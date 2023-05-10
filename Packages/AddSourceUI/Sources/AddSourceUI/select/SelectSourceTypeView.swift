//
//  SelectSourceTypeView.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI
import CardUI
import SharedUI
import DataModel

typealias SelectHandler = (Model, ModelVariant) -> Void

struct CardContentView: View {
  let source: SourceViewModel

  var body: some View {
    VStack {
      HStack {
        Text(source.name)
          .fontWeight(.semibold)
          .frame(maxWidth: .infinity, alignment: .leading)
        Spacer()
        if source.isRemote {
          PillView(
            label: "Downloadable", style: .outlined(
              borderColor: Color(light: .init(hex: "#F9B9D8"), dark: .init(hex: "#FF2B91", opacity: 0.3)),
              textColor: Color(light: .init(hex: "#D33984"), dark: .init(hex: "#D33984"))
            )
          )
        }
        if !source.isRemote {
          ForEach(source.variantRows, id: \.id) { variant in
            PillView(label: variant.label, style: .filled())
          }
        }
        ForEach(source.languages, id: \.code) { language in
          PillView(label: language.label, iconName: "globe.desk")
        }
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
          ForEach(viewModel.cards, id: \.contentViewModel.id) { card in
            CardView(viewModel: card) { source in
              CardContentView(source: source)
            } body: { source in
              VStack(spacing: 0) {
                ForEach(source.variantRows, id: \.id) { rowViewModel in
                  SelectableCardContentRowView(viewModel: rowViewModel, hasBottomBorder: rowViewModel !== source.variantRows.last)
                }
              }
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
