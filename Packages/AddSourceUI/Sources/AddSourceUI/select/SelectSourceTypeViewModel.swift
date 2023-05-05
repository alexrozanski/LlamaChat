//
//  SelectSourceTypeViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation
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

  init(dependencies: Dependencies, selectSourceHandler: @escaping SelectSourceHandler) {
    self.dependencies = dependencies
    self.selectSourceHandler = selectSourceHandler

    sources = dependencies.remoteMetadataModel.allModels.map { remoteModel in
      return Source(name: remoteModel.name, publisher: remoteModel.publisher.name)
    }
  }

  func select(sourceType: ChatSourceType) {
    selectSourceHandler(sourceType)
  }
}
