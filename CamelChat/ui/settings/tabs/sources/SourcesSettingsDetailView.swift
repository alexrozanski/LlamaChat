//
//  SourcesSettingsDetailView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct SourcesSettingsDetailView: View {
  var source: ChatSource

  var body: some View {
    Text(source.name)
  }
}
