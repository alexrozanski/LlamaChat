//
//  RemoteMetadataModel.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation
import DataModel
import RemoteModels

public class RemoteMetadataModel: ObservableObject {
  let apiBaseURL: URL

  @Published public var allModels: [Model] = []

  private lazy var fetcher = RemoteModelMetadataFetcher(apiBaseURL: apiBaseURL)

  public init(apiBaseURL: URL) {
    self.apiBaseURL = apiBaseURL

    fetcher.$allModels
      .map { $0.map { remoteModel in Model(remote: remoteModel) } }
      .assign(to: &$allModels)
  }

  public func fetchMetadata() {
    fetcher.updateMetadata()
  }
}

fileprivate extension Model {
  convenience init(remote: RemoteModel) {
    self.init(name: remote.name, publisher: .init(remote: remote.publisher))
  }
}

fileprivate extension ModelPublisher {
  convenience init(remote: RemoteModelPublisher) {
    self.init(name: remote.name)
  }
}
