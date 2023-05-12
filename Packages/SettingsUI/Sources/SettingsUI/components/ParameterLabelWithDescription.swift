//
//  ParameterLabelWithDescription.swift
//  
//
//  Created by Alex Rozanski on 11/05/2023.
//

import SwiftUI

struct ShowParameterDetailsKey: EnvironmentKey {
  static let defaultValue: Bool = false
}

extension EnvironmentValues {
  var showParameterDetails: Bool {
    get { self[ShowParameterDetailsKey.self] }
    set { self[ShowParameterDetailsKey.self] = newValue }
  }
}

public struct ParameterLabelWithDescription: View {
  let label: String
  let description: String

  @Environment(\.showParameterDetails) var showParameterDetails

  public init(label: String, description: String) {
    self.label = label
    self.description = description
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(label)
      if showParameterDetails {
        Text(description)
          .font(.footnote)
          .foregroundColor(.gray)
      }
    }
  }
}
