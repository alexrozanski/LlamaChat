//
//  DownloadsManager.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import Foundation
import Alamofire

class DownloadsManager {
  enum ReachabilityStatus {
    case reachable(contentLength: Int64?)
    case notReachable
  }

  init() {}

  func checkReachability(of url: URL) async -> ReachabilityStatus {
    return await withCheckedContinuation { continuation in
      AF.request(url, method: .head).response { response in
        continuation.resume(returning: .reachable(contentLength: response.response?.expectedContentLength))
      }
    }
  }
}
