//
//  SelectSourceTypeViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation
import Combine
import AppModel
import CardUI
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

  @Published private(set) var cards: [CardViewModel<SourceViewModel>] = []
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
      .map { models in
        return Array(
          Set<Language>(
            models.flatMap { $0.languages.compactMap { code in Language(code: code) } }
          )
        )
        .sorted { $0.label < $1.label }
      }
      .assign(to: &filterViewModel.$availableLanguages)

    dependencies.remoteMetadataModel.$allModels
      .combineLatest(filterViewModel.$location, filterViewModel.$language, filterViewModel.$searchFieldText)
      .compactMap { [weak self] models, location, language, searchFieldText -> (sources: [SourceViewModel], matches: [SourceFilterMatch])? in
        guard let self else { return nil }

        return filterSources(
          models: models,
          location: location,
          language: language,
          searchFieldText: searchFieldText,
          viewModel: self
        )
      }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] (sources, matches) in
        self?.cards = sources.map { source in
          CardViewModel(
            contentViewModel: source,
            isSelectable: source.isModelSelectable,
            hasBody: source.hasSelectableVariants,
            selectionHandler: { [weak self] in
              self?.selectModel(source.model, variant: nil)
            }
          )
        }
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
      .combineLatest($cards, filterViewModel.$hasFilters, filterViewModel.$searchFieldText)
      .map { isLoading, cards, hasFilters, searchFieldText in
        if isLoading && cards.isEmpty {
          return .loading
        }
        
        if (hasFilters || !searchFieldText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) && cards.isEmpty {
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
  language: Language?,
  searchFieldText: String,
  viewModel: SelectSourceTypeViewModel
) -> (sources: [SourceViewModel], matches: [SourceFilterMatch]) {
  let availableModels = models.filter { !$0.legacy }
  let trimmedSearchText = searchFieldText.trimmingCharacters(in: .whitespacesAndNewlines)

  guard location != nil || language != nil || !trimmedSearchText.isEmpty else {
    return (
      availableModels.map { model in
        SourceViewModel(model: model, matches: nil, selectionHandler: { variant in
          viewModel.selectModel(model, variant: variant)
        })
      }, [])
  }

  return availableModels
    .compactMap { model -> (Model, [SourceFilterMatch])? in
      var sourceMatches = [SourceFilterMatch]()

      if !trimmedSearchText.isEmpty {
        let textMatches = sourceFilterMatches(in: model, trimmedSearchText: trimmedSearchText)
        guard !textMatches.isEmpty else { return nil }
        sourceMatches.append(contentsOf: textMatches)
      }

      if let location {
        guard location.matches(source: model.source) else { return nil }
        sourceMatches.append(.location)
      }

      if let language {
        guard model.languages.contains(language.code) else { return nil }
        sourceMatches.append(.language)
      }

      return (model, sourceMatches)
    }
    .reduce((sources: [SourceViewModel](), matches: [SourceFilterMatch]())) { acc, result in
      let (lastSources, lastMatches) = acc
      let (model, matches) = result

      // It's okay to only pass the current matches to Source() as they relate to the current source.
      return (
        lastSources + [
          SourceViewModel(
            model: model,
            matches: matches,
            selectionHandler: { variant in
              viewModel.selectModel(model, variant: variant)
            }
          )
        ],
        lastMatches + matches)
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
