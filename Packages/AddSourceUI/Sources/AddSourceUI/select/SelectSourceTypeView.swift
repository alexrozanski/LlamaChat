//
//  SelectSourceTypeView.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI
import SharedUI
import RemoteModels

fileprivate struct Colors {
  static let border = Color(light: Color(hex: "#DEDEDE"), dark: Color(hex: "#DEDEDE"))
  static let hoverBackground = Color.black.opacity(0.02)
}

typealias SelectHandler = (RemoteModel, RemoteModelVariant) -> Void

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
              borderColor: Color(light: .init(hex: "#F9B9D8"), dark: .init(hex: "#F9B9D8")),
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
      Color(nsColor: .controlBackgroundColor)
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

struct SelectSourceTypeView: View {
  @ObservedObject var viewModel: SelectSourceTypeViewModel

  var body: some View {
      VStack(alignment: .leading, spacing: 20) {
        SelectSourceTypeFilterView(viewModel: viewModel.filterViewModel)
          .zIndex(10)
        if viewModel.showLoadingSpinner {
          VStack {
            Spacer()
            HStack {
              Spacer()
              DebouncedView {
                ProgressView()
                  .progressViewStyle(.circular)
                  .controlSize(.small)
              }
              Spacer()
            }
            Spacer()
          }
        } else {
          ScrollView {
            VStack {
              ForEach(viewModel.sources, id: \.id) { source in
                SourceTypeView(source: source) { model, variant in
                  viewModel.selectModel(model, variant: variant)
                }
              }
            }
          }
          .zIndex(0)
        }
      }
  }
}
