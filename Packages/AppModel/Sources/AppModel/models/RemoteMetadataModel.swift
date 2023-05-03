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

  @Published var allModels: [Model] = []

  private lazy var fetcher = RemoteModelMetadataFetcher(apiBaseURL: apiBaseURL)

  public init(apiBaseURL: URL) {
    self.apiBaseURL = apiBaseURL

    fetcher.$allModels
      .map { $0.map { remoteModel in Model(name: remoteModel.name) } }
      .assign(to: &$allModels)
  }

  func fetchMetadata() {
    fetcher.updateMetadata()
  }
}
