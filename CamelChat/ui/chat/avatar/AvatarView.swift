//
//  AvatarView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import SwiftUI

struct AvatarView: View {
  enum Size {
    case medium
    case large

    var sideLength: Double {
      switch self {
      case .medium: return 40
      case .large: return 48
      }
    }

    var textSideLength: Double {
      switch self {
      case .medium: return 30
      case .large: return 35
      }
    }

    var fontSize: Double {
      switch self {
      case .medium: return 20
      case .large: return 24
      }
    }
  }

  @ObservedObject var viewModel: AvatarViewModel
  var size: Size

  var body: some View {
    Circle()
      .fill(.gray)
      .frame(width: size.sideLength, height: size.sideLength)
      .overlay {
        Text(viewModel.initials)
          .font(.system(size: size.fontSize))
          .lineLimit(1)
          .minimumScaleFactor(0.5)
          .foregroundColor(.white)
          .frame(width: size.textSideLength, height: size.textSideLength)
      }
  }
}
