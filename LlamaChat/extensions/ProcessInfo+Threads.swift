//
//  ProcessInfo+Threads.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 17/04/2023.
//

import Foundation

extension ProcessInfo {
  var defaultThreadCount: Int {
    let activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
    if activeProcessorCount < 4 {
      return activeProcessorCount
    }

    return max(ProcessInfo.processInfo.activeProcessorCount - 2, 4)
  }

  var threadCountRange: ClosedRange<Int> {
    // In practice we should be running on 4+ cores but have this as a fallback
    // just in case.
    let activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
    if activeProcessorCount < 4 {
      return 1...activeProcessorCount
    }

    return 4...activeProcessorCount
  }
}
