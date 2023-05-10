//
//  CardViewModel.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import Foundation

public class CardViewModel<ContentViewModel>: ObservableObject {
  public typealias SelectionHandler = () -> Void

  public let contentViewModel: ContentViewModel
  private let selectionHandler: SelectionHandler

  @Published public var isSelectable: Bool
  @Published public var hasBody: Bool

  public init(
    contentViewModel: ContentViewModel,
    isSelectable: Bool,
    hasBody: Bool,
    selectionHandler: @escaping SelectionHandler
  ) {
    self.contentViewModel = contentViewModel
    self.isSelectable = isSelectable
    self.hasBody = hasBody
    self.selectionHandler = selectionHandler
  }

  func select() {
    if isSelectable {
      selectionHandler()
    }
  }
}
