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

  @State var height: Double = 0

  @ViewBuilder var readyToDownload: some View {
    switch viewModel.state {
    case .none, .checkingReachability, .failedToDownload, .cannotDownload:
      EmptyView()
    case .readyToDownload(let contentLength):
      Section {
        Group {
          if let contentLength, let availableSpace = viewModel.availableSpace {
            Text("The GPT4All model can be downloaded automatically, and will take up **\(ByteCountFormatter().string(fromByteCount: contentLength))** of disk space.\n\nYou have **\(ByteCountFormatter().string(fromByteCount: availableSpace))** available.")
              .lineLimit(nil)
              .fixedSize(horizontal: false, vertical: true)
              .frame(alignment: .leading)
          } else {
            Text("The GPT4All model can be downloaded automatically.")
          }
        }
      }
    case .downloadingModel:
      Section {
        VStack(alignment: .leading) {
          let title = HStack(spacing: 4) {
            Text("Downloading model from")
            Text(viewModel.downloadURL.absoluteString)
              .font(.system(size: 12, weight: .regular, design: .monospaced))
          }
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
            case .deterministic(downloadedBytes: let downloadedBytes, totalBytes: let totalBytes, progress: let progress, estimatedTimeRemaining: let estimatedTimeRemaining):
              title
              ProgressView("", value: progress)
                .progressViewStyle(.linear)
              Group {
                if let estimatedTimeRemaining {
                  Text("Downloading \(ByteCountFormatter().string(fromByteCount: downloadedBytes)) of \(ByteCountFormatter().string(fromByteCount: totalBytes)) (\(estimatedTimeRemaining) remaining)")
                    .font(.footnote)
                } else {
                  Text("Downloading \(ByteCountFormatter().string(fromByteCount: downloadedBytes)) of \(ByteCountFormatter().string(fromByteCount: totalBytes))")
                    .font(.footnote)
                }
              }
            }
          }
        }
      }
    case .downloadedModel:
      Section {
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
  }

  var body: some View {
    Form {
      ConfigureSourceDetailsView(viewModel: viewModel.detailsViewModel)
      reachabilityProgress
      readyToDownload
    }
    .formStyle(.grouped)
    .onAppear {
      viewModel.start()
    }
  }
}
