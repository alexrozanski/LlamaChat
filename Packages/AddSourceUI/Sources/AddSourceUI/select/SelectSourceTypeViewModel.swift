//
//  SelectSourceTypeViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation
import Combine
import AppModel
import DataModel

class SelectSourceTypeViewModel: ObservableObject {
  typealias SelectSourceHandler = (ChatSourceType) -> Void

  struct Source {
    let name: String
    let publisher: String
  }

  @Published var sources: [Source]

  private let dependencies: Dependencies
  private let selectSourceHandler: SelectSourceHandler

  let filterViewModel: SelectSourceTypeFilterViewModel

  private var subscriptions = Set<AnyCancellable>()

  init(dependencies: Dependencies, selectSourceHandler: @escaping SelectSourceHandler) {
    let filterViewModel = SelectSourceTypeFilterViewModel()

    self.dependencies = dependencies
    self.selectSourceHandler = selectSourceHandler
    self.filterViewModel = filterViewModel

    sources = filteredSources(
      models: dependencies.remoteMetadataModel.allModels,
      location: filterViewModel.location
    )

    filterViewModel.$location.sink { [weak self] newLocation in
      self?.filterSources(location: newLocation)
    }.store(in: &subscriptions)
  }

  func select(sourceType: ChatSourceType) {
    selectSourceHandler(sourceType)
  }

  private func filterSources(location: String?) {
    sources = filteredSources(
      models: dependencies.remoteMetadataModel.allModels,
      location: location
    )
  }
}

private func filteredSources(models: [Model], location: String?) -> [SelectSourceTypeViewModel.Source] {
  return models
    .filter { remoteModel in
      if location != nil {
        return false
      }
      return true
    }
    .map { remoteModel in
      return SelectSourceTypeViewModel.Source(name: remoteModel.name, publisher: remoteModel.publisher.name)
    }
}
