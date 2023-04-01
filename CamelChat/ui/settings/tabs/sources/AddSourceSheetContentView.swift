//
//  AddSourceSheetContentView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

class AddSourceSheetViewModel: SheetViewModel, ObservableObject {
  enum State {
    case none
    case selectingSource(viewModel: SelectSourceTypeViewModel)
    case configuringSource(viewModel: ConfigureSourceViewModel)
  }

  private let chatSources: ChatSources
  private let closeHandler: () -> Void

  @Published var state: State = .none

  init(chatSources: ChatSources, closeHandler: @escaping () -> Void) {
    self.chatSources = chatSources
    self.closeHandler = closeHandler
  }

  func start() {
    state = .selectingSource(
      viewModel: SelectSourceTypeViewModel(
        chatSources: chatSources,
        selectSourceHandler: { [weak self] sourceType in
          self?.configureSource(with: sourceType)
        }
      )
    )
  }

  private func configureSource(with type: ChatSourceType) {
    let viewModel: ConfigureSourceViewModel
    switch type {
    case .llama:
      viewModel = makeConfigureLocalLlamaModelSourceViewModel(
        addSourceHandler: { [weak self] source in
          self?.add(source: source)
        }, goBackHandler: { [weak self] in
          self?.goBack()
        }
      )
    case .alpaca:
      viewModel = makeConfigureLocalAlpacaModelSourceViewModel(
        addSourceHandler:{ [weak self] source in
          self?.add(source: source)
        }, goBackHandler: { [weak self] in
          self?.goBack()
        }
      )
    }

    state = .configuringSource(viewModel: viewModel)
  }

  private func goBack() {
    switch state {
    case .none, .selectingSource(viewModel: _):
      break
    case .configuringSource(viewModel: _):
      start()
    }
  }

  private func add(source: ChatSource) {
    chatSources.add(source: source)
    closeHandler()
  }

  func cancel() {
    closeHandler()
  }
}

struct AddSourceSheetContentView: View {
  @ObservedObject var viewModel: AddSourceSheetViewModel

  @ViewBuilder var contentView: some View {
    switch viewModel.state {
    case .none:
      EmptyView()
    case .selectingSource(viewModel: let viewModel):
      VStack {
        SelectSourceTypeView(viewModel: viewModel)
        HStack {
          Button("Cancel") { self.viewModel.cancel() }
          Spacer()
        }
        .padding(.top, 12)
      }
      .padding()
    case .configuringSource(viewModel: let viewModel):
      makeConfigureSourceView(from: viewModel)
    }
  }

  var body: some View {
    VStack {
      contentView
    }
    .frame(minWidth: 500, minHeight: 300)
    .onAppear() {
      viewModel.start()
    }
  }
}
