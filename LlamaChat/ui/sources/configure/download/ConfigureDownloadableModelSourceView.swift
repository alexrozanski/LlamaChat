//
//  ConfigureDownloadableModelSourceView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import SwiftUI

struct ConfigureDownloadableModelSourceView: View {
  @ObservedObject var viewModel: ConfigureDownloadableModelSourceViewModel

  @ViewBuilder var reachabilityProgress: some View {
    if viewModel.state.isCheckingReachability {
      Section {
        LabeledContent { Text("") } label: { Text("") }
        .overlay(
          ProgressView()
            .progressViewStyle(.circular)
            .controlSize(.small)
        )
      }
    }
  }

  @ViewBuilder var readyToDownload: some View {
    switch viewModel.state {
    case .none, .checkingReachability, .cannotDownload:
      EmptyView()
    case .readyToDownload(let contentLength):
      Section {
        LabeledContent { Text("") } label: { Text("") }
        .overlay(
          Group {
            if let contentLength {
              Text("The GPT4All model can be downloaded automatically, and will take up **\(ByteCountFormatter().string(fromByteCount: contentLength))** of disk space.")
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
              Text("The GPT4All model can be downloaded automatically.")
            }
          }
        )
      }
    }
  }

  var body: some View {
    Form {
      reachabilityProgress
      readyToDownload
    }
    .formStyle(.grouped)
    .onAppear {
      viewModel.start()
    }
  }
}

