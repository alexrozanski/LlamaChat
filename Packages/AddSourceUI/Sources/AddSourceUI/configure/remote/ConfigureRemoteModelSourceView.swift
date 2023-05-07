//
//  ConfigureDownloadableModelSourceView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import SwiftUI

struct ConfigureRemoteModelSourceView: View {
  @ObservedObject var viewModel: ConfigureRemoteModelSourceViewModel

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
          Text("This model can be downloaded automatically.")
        }
      }
      Section {
        LabeledContent {
          Text(viewModel.variantName)
        } label: {
          Text("Model Variant")
        }
        LabeledContent {
          Text(viewModel.downloadURL.absoluteString)
        } label: {
          Text("Download URL")
        }
        if let contentLength {
          LabeledContent {
            Text(ByteCountFormatter().string(fromByteCount: contentLength))
          } label: {
            Text("Download Size")
          }
        }
        if let availableSpace = viewModel.availableSpace {
          LabeledContent {
            Text(ByteCountFormatter().string(fromByteCount: availableSpace))
          } label: {
            Text("Available Space")
          }
        }
      }
    case .downloadingModel:
      Section {
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
