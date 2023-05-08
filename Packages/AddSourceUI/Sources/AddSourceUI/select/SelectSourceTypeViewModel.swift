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
import ModelMetadata

class SelectSourceTypeViewModel: ObservableObject {
  typealias SelectModelHandler = (Model, ModelVariant?) -> Void

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
      .map { [weak self] models, location, searchFieldText in
        return filterSources(
          models: models,
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

  func selectModel(_ model: Model, variant: ModelVariant?) {
    selectModelHandler(model, variant)
  }
}

private func filterSources(
  models: [Model],
  location: SelectSourceTypeFilterViewModel.Location?,
  searchFieldText: String,
  selectionHandler: @escaping (Model, ModelVariant?) -> Void
) -> (sources: [SourceViewModel], matches: [SourceFilterMatch]) {
  let availableModels = models.filter { !$0.legacy }
  let trimmedSearchText = searchFieldText.trimmingCharacters(in: .whitespacesAndNewlines)

  guard location != nil || !trimmedSearchText.isEmpty else {
    return (
      availableModels.map { model in
        SourceViewModel(model: model, matches: nil, selectionHandler: { variant in
          selectionHandler(model, variant)
        })
      },
      []
    )
  }

  return availableModels
    .map { model -> (Model, [SourceFilterMatch]) in
      var sourceMatches = [SourceFilterMatch]()

      if !trimmedSearchText.isEmpty {
        sourceMatches.append(contentsOf: sourceFilterMatches(in: model, trimmedSearchText: trimmedSearchText))
      }

      if let location, location.matches(source: model.source) {
        sourceMatches.append(.modelLocation)
      }

      return (model, sourceMatches)
    }
    .filter { (model, matches) in !matches.isEmpty }
    .reduce((sources: [SourceViewModel](), matches: [SourceFilterMatch]())) { acc, result in
      let (lastSources, lastMatches) = acc
      let (model, matches) = result

      if matches.isEmpty {
        return acc
      } else {
        // It's okay to only pass the current matches to Source() as they relate to the current source.
        return (
          lastSources + [
            SourceViewModel(
              model: model,
              matches: matches,
              selectionHandler: { variant in
                selectionHandler(model, variant)
              }
            )
          ],
          lastMatches + matches)
      }
    }
}

fileprivate extension SelectSourceTypeFilterViewModel.Location {
  func matches(source: Model.Source) -> Bool {
    switch source {
    case .remote:
      return self == .remote
    case .local:
      return self == .local
    }
  }
}

fileprivate func sourceFilterMatches(in model: Model, trimmedSearchText: String) -> [SourceFilterMatch] {
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
