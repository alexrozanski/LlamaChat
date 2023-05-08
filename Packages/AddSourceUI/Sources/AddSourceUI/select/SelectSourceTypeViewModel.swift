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
  typealias SelectModelHandler = (RemoteModel, RemoteModelVariant?) -> Void

  enum Content {
    case none
    case loading
    case emptyFilter
    case sources
  }

  @Published private(set) var sources: [SourceViewModel] = []
  @Published private(set) var matches: [SourceFilterMatch] = []

  @Published private(set) var content: Content = .none

  private let dependencies: Dependencies
  private let selectModelHandler: SelectModelHandler

  let filterViewModel: SelectSourceTypeFilterViewModel

  private var subscriptions = Set<AnyCancellable>()

  init(dependencies: Dependencies, selectModelHandler: @escaping SelectModelHandler) {
    let filterViewModel = SelectSourceTypeFilterViewModel()

    self.dependencies = dependencies
    self.selectModelHandler = selectModelHandler
    self.filterViewModel = filterViewModel

    dependencies.remoteMetadataModel.$allModels
      .combineLatest(filterViewModel.$location, filterViewModel.$searchFieldText)
      .map { [weak self] remoteModels, location, searchFieldText in
        return filterSources(
          models: remoteModels,
          location: location,
          searchFieldText: searchFieldText,
          selectionHandler: { model, variant in
            self?.selectModel(model, variant: variant)
          }
        )
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
      .combineLatest($sources, filterViewModel.$hasFilters, filterViewModel.$searchFieldText)
      .map { isLoading, sources, hasFilters, searchFieldText in
        if isLoading && sources.isEmpty {
          return .loading
        }
        
        if (hasFilters || !searchFieldText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) && sources.isEmpty {
          return .emptyFilter
        }

        return .sources
      }
      .assign(to: &$content)
  }

  func selectModel(_ model: RemoteModel, variant: RemoteModelVariant?) {
    selectModelHandler(model, variant)
  }
}

private func filterSources(
  models: [RemoteModel],
  location: SelectSourceTypeFilterViewModel.Location?,
  searchFieldText: String,
  selectionHandler: @escaping (RemoteModel, RemoteModelVariant?) -> Void
) -> (sources: [SourceViewModel], matches: [SourceFilterMatch]) {
  let availableModels = models.filter { !$0.legacy }
  let trimmedSearchText = searchFieldText.trimmingCharacters(in: .whitespacesAndNewlines)

  guard location != nil || !trimmedSearchText.isEmpty else {
    return (
      availableModels.map { model in
        SourceViewModel(remoteModel: model, matches: nil, selectionHandler: { variant in
          selectionHandler(model, variant)
        })
      },
      []
    )
  }

  return availableModels
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
    .reduce((sources: [SourceViewModel](), matches: [SourceFilterMatch]())) { acc, result in
      let (lastSources, lastMatches) = acc
      let (remoteModel, matches) = result

      if matches.isEmpty {
        return acc
      } else {
        // It's okay to only pass the current matches to Source() as they relate to the current source.
        return (
          lastSources + [
            SourceViewModel(
              remoteModel: remoteModel,
              matches: matches,
              selectionHandler: { variant in
                selectionHandler(remoteModel, variant)
              }
            )
          ],
          lastMatches + matches)
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
