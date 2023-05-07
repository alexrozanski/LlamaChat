//
//  SelectTypePill.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import SwiftUI
import SharedUI

struct SelectTypePillView: View {
  enum Style {
    case outlined(borderColor: Color? = nil, textColor: Color? = nil, iconColor: Color? = nil)
    case filled(backgroundColor: Color? = nil, textColor: Color? = nil, iconColor: Color? = nil)
  }

  let label: String
  let iconName: String?
  let style: Style

  init(
    label: String,
    iconName: String? = nil,
    style: Style = .outlined()
  ) {
    self.label = label
    self.iconName = iconName
    self.style = style
  }

  @ViewBuilder private var background: some View {
    switch style {
    case .outlined(borderColor: let borderColor, textColor: _, iconColor: _):
      RoundedRectangle(cornerRadius: 4)
        .stroke(borderColor ?? Color(light: .init(hex: "#C6B9F9"), dark: .init(hex: "#4A26D9", opacity: 0.8)))
    case .filled(backgroundColor: let backgroundColor, textColor: _, iconColor: _):
      RoundedRectangle(cornerRadius: 4)
        .fill(backgroundColor ?? Color(light: .init(hex: "#F2EFFF"), dark: .init(hex: "#4617FF", opacity: 0.3)))
    }
  }

  private var textColor: Color {
    switch style {
    case .outlined(borderColor: _, textColor: let textColor, iconColor: _):
      return textColor ?? Color(light: .init(hex: "#5839D3"), dark: .init(hex: "#6441EF"))
    case .filled(backgroundColor: _, textColor: let textColor, iconColor: _):
      return textColor ?? Color(light: .init(hex: "#6854BA"), dark: .init(hex: "#7553FE"))
    }
  }

  private var iconColor: Color {
    switch style {
    case .outlined(borderColor: _, textColor: _, iconColor: let iconColor):
      return iconColor ?? Color(light: .init(hex: "#8A72EC"), dark: .init(hex: "#6038FE"))
    case .filled(backgroundColor: _, textColor: _, iconColor: let iconColor):
      return iconColor ?? Color(light: .init(hex: "#6854BA"), dark: .init(hex: "#6038FE"))
    }
  }

  var body: some View {
    HStack(spacing: 2) {
      if let iconName {
        Image(systemName: iconName)
          .foregroundColor(iconColor)
          .font(.system(size: 12))
      }
      Text(label)
        .foregroundColor(textColor)
        .font(.system(size: 11, weight: .medium))
    }
    .padding(EdgeInsets(top: 1, leading: 4, bottom: 2, trailing: 4))
    .background(background)
  }
}
