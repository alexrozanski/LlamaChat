//
//  RemoteModelMetadataFetcher.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation
import Alamofire

struct ResponsePayload: Decodable {
  let models: [RemoteModel]
}

public class RemoteModelMetadataFetcher {
  let apiBaseURL: URL

  @Published public private(set) var allModels: [RemoteModel] = []
  
  public init(apiBaseURL: URL) {
    self.apiBaseURL = apiBaseURL
  }

  private var fetchURL: URL {
    return apiBaseURL.appending(components: "v1", "models")
  }

  public func updateMetadata() {
    AF.request(fetchURL).responseDecodable(of: ResponsePayload.self) { [weak self] response in
      do {
        let payload = try response.result.get()
        self?.allModels = payload.models
      } catch {
        print("Error downloading metadata", error)
      }
    }
  }
}
