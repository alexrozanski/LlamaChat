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
import RemoteModels

class SelectSourceTypeViewModel: ObservableObject {
  typealias SelectSourceHandler = (ChatSourceType) -> Void

  @Published private(set) var sources: [Source] = []
  @Published private(set) var matches: [SourceFilterMatch] = []
  @Published private(set) var showLoadingSpinner = false

  private let dependencies: Dependencies
  private let selectSourceHandler: SelectSourceHandler

  let filterViewModel: SelectSourceTypeFilterViewModel

  private var subscriptions = Set<AnyCancellable>()

  init(dependencies: Dependencies, selectSourceHandler: @escaping SelectSourceHandler) {
    let filterViewModel = SelectSourceTypeFilterViewModel()

    self.dependencies = dependencies
    self.selectSourceHandler = selectSourceHandler
    self.filterViewModel = filterViewModel

    dependencies.remoteMetadataModel.$allModels
      .combineLatest(filterViewModel.$location, filterViewModel.$searchFieldText)
      .map { remoteModels, location, searchFieldText in
        return filterSources(models: remoteModels, location: location, searchFieldText: searchFieldText)
      }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] (sources, matches) in
        self?.sources = sources
        self?.matches = matches
      }.store(in: &subscriptions)

    dependencies.remoteMetadataModel.$loadState
      .map { loadState in
        switch loadState {
        case .none, .failed, .loaded:
          return false
        case .loading:
          return true
        }
      }
      .combineLatest(dependencies.remoteMetadataModel.$allModels)
      .map { isLoading, allModels in
        return isLoading && allModels.isEmpty
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$showLoadingSpinner)
  }

  func select(sourceType: ChatSourceType) {
    selectSourceHandler(sourceType)
  }
}

private func filterSources(
  models: [RemoteModel],
  location: SelectSourceTypeFilterViewModel.Location?,
  searchFieldText: String
) -> (sources: [Source], matches: [SourceFilterMatch]) {
  let trimmedSearchText = searchFieldText.trimmingCharacters(in: .whitespacesAndNewlines)
  guard location != nil || !trimmedSearchText.isEmpty else {
    return (models.map { Source(remoteModel: $0, matches: nil)}, [])
  }

  return models
    .map { remoteModel -> (RemoteModel, [SourceFilterMatch]) in
      var sourceMatches = [SourceFilterMatch]()

      if !trimmedSearchText.isEmpty {
        sourceMatches.append(contentsOf: sourceFilterMatches(in: remoteModel, trimmedSearchText: trimmedSearchText))
      }

      if let location, location.matches(source: remoteModel.source) {
        sourceMatches.append(.modelLocation)
      }

      return (remoteModel, sourceMatches)
    }
    .filter { (remoteModel, matches) in !matches.isEmpty }
    .reduce((sources: [Source](), matches: [SourceFilterMatch]())) { acc, result in
      let (lastSources, lastMatches) = acc
      let (remoteModel, matches) = result

      if matches.isEmpty {
        return acc
      } else {
        // It's okay to only pass the current matches to Source() as they relate to the current source.
        return (lastSources + [Source(remoteModel: remoteModel, matches: matches)], lastMatches + matches)
      }
    }
}

fileprivate extension SelectSourceTypeFilterViewModel.Location {
  func matches(source: RemoteModel.Source) -> Bool {
    switch source {
    case .remote:
      return self == .remote
    case .local:
      return self == .local
    }
  }
}

fileprivate func sourceFilterMatches(in model: RemoteModel, trimmedSearchText: String) -> [SourceFilterMatch] {
  var matches = [SourceFilterMatch]()
  if model.name.range(of: trimmedSearchText, options: .caseInsensitive) != nil {
    matches.append(.modelName(id: model.id))
  }

  model.variants.forEach { variant in
    if variant.name.range(of: trimmedSearchText, options: .caseInsensitive) != nil {
      matches.append(.variantName(modelId: model.id, variantId: variant.id))
    }
  }

  return matches
}
