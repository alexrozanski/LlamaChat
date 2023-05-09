//
//  PrimaryActionsViewModel.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import Foundation

class PrimaryActionsViewModel: ObservableObject {
  @Published var continueButton: PrimaryActionsButton? = nil
  @Published var otherButtons: [PrimaryActionsButton] = []
}
