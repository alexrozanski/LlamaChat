//
//  ConfigureDownloadableModelView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import SwiftUI
import CardUI

struct ConfigureDownloadableModelView: View {
  @ObservedObject var viewModel: ConfigureDownloadableModelViewModel

  @ViewBuilder var reachabilityProgress: some View {
    if viewModel.state.isCheckingReachability {
        ProgressView()
          .progressViewStyle(.circular)
          .controlSize(.small)
          .padding()
    }
  }

  @State var height: Double = 0

  @ViewBuilder var readyToDownload: some View {
    switch viewModel.state {
    case .none, .checkingReachability, .failedToDownload, .cannotDownload:
      EmptyView()
    case .readyToDownload(let contentLength):
      VStack(alignment: .leading, spacing: 0) {
        CardContentRowView(label: "Model Variant", hasBottomBorder: true) {
          Text(viewModel.variantName)
        }
        CardContentRowView(label: "Download URL", hasBottomBorder: true) {
          Text(viewModel.downloadURL.absoluteString)
        }
        if let contentLength {
          CardContentRowView(label: "Download Size", hasBottomBorder: true) {
            Text(ByteCountFormatter().string(fromByteCount: contentLength))
          }
        }
        if let availableSpace = viewModel.availableSpace {
          CardContentRowView(label: "Available Space", hasBottomBorder: false) {
            Text(ByteCountFormatter().string(fromByteCount: availableSpace))
          }
        }
      }
    case .downloadingModel:
      VStack(alignment: .leading) {
        let title = Text((try? AttributedString(markdown: "Downloading model from `\(viewModel.downloadURL.absoluteString)`")) ?? AttributedString())
        if let downloadProgress = viewModel.downloadProgress {
          switch downloadProgress {
          case .nonDeterministic:
            HStack {
              title
              Spacer()
              ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.small)
            }
          case .deterministic(downloadedBytes: let downloadedBytes, totalBytes: let totalBytes, progress: let progress):
            title
            ProgressView("", value: progress)
              .progressViewStyle(.linear)
            Text("Downloading \(ByteCountFormatter().string(fromByteCount: downloadedBytes)) of \(ByteCountFormatter().string(fromByteCount: totalBytes))")
              .font(.footnote)
          }
        }
      }
    case .downloadedModel:
      HStack {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
          Text("Successfully downloaded file")
          Spacer()
        }
      }
    }
  }

  var body: some View {
    VStack {
      reachabilityProgress
      readyToDownload
    }
    .onAppear {
      viewModel.start()
    }
  }
}
