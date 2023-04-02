//
//  Message.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation
import Combine

protocol Message {
  var id: UUID { get }
  var sender: Sender { get }
  var content: String { get }
  var sendDate: Date { get }
  var isError: Bool { get }
}
