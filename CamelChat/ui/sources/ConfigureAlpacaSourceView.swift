//
//  ConfigureAlpacaSourceView.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI

struct ConfigureAlpacaSourceView: View {
  @ObservedObject var viewModel: ConfigureAlpacaSourceViewModel

  var body: some View {
    VStack(alignment: .leading) {
      Text("Set up Alpaca")
        .font(.headline)
    }
  }
}
