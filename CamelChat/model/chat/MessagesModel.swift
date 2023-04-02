//
//  MessagesModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import Foundation
import SQLite

class MessagesModel {
  private lazy var databaseURL: URL? = {
    return applicationSupportDirectoryURL()?.appending(path: "messages.db")
  }()

  private lazy var db: Connection? = {
    return databaseURL.flatMap { try? Connection($0.path) }
  }()

  private let chatSourcesTable = Table("chat_sources")
  private let messagesTable = Table("messages")

  private let idColumn = Expression<Int64>("id")

  private let chatIdColumn = Expression<String>("chat_id")
  
  private let seqColumn = Expression<Int64>("seq")
  private let chatSourceIdColumn = Expression<Int64>("chat_source_id")
  private let isMeColumn = Expression<Bool>("is_me")
  private let messageColumn = Expression<String>("message")
  private let sendDateColumn = Expression<Date>("send_date")
  private let isErrorColumn = Expression<Bool>("is_error")

  private func setUpSchema() {
    do {
      try db?.run(chatSourcesTable.create(ifNotExists: true) { t in
        t.column(idColumn, primaryKey: true)
        t.column(chatIdColumn, unique: true)
      })

      try db?.run(messagesTable.create(ifNotExists: true) { t in
        t.column(idColumn, primaryKey: true)
        t.column(seqColumn)
        t.column(chatSourceIdColumn)
        t.column(isMeColumn)
        t.column(messageColumn)
        t.column(sendDateColumn)
        t.column(isErrorColumn)
      })
    } catch {
      print(error)
    }
  }

  init() {
    setUpSchema()
  }

  func loadMessages(from chatSource: ChatSource) -> [Message] {
    do {
      guard let db else { return [] }

      guard let chatSourceId = try getId(for: chatSource) else {
        return []
      }

      let messagesQuery = try db.prepare(
        messagesTable
          .where(chatSourceIdColumn == chatSourceId)
          .order(seqColumn.asc)
      )

      var messages = [Message]()
      for message in messagesQuery {
        let isMe = message[isMeColumn]
        messages.append(
          StaticMessage(
            content: message[messageColumn],
            sender: isMe ? .me : .other,
            sendDate: message[sendDateColumn],
            isError: message[isErrorColumn]
          )
        )
      }
      return messages
    } catch {
      print(error)
      return []
    }
  }

  func append(message: Message, in chatSource: ChatSource) {
    do {
      guard
        let db,
        let chatSourceId = try insertChatSourceIfNeeded(chatSource)
      else { return }

      let lastSeq = try db.scalar(messagesTable.select(seqColumn.max).where(chatSourceIdColumn == chatSourceId)) ?? 0
      let insert = messagesTable.insert(
        seqColumn <- lastSeq + 1,
        chatSourceIdColumn <- chatSourceId,
        isMeColumn <- message.sender.isMe,
        messageColumn <- message.content,
        sendDateColumn <- message.sendDate,
        isErrorColumn <- message.isError
      )
      _ = try db.run(insert)
    } catch {
      print(error)
    }
  }

  private func getId(for chatSource: ChatSource) throws -> Int64? {
    guard let db else { return nil }
    return try db.pluck(chatSourcesTable.select(idColumn).where(chatIdColumn == chatSource.id))?[idColumn]
  }

  private func insertChatSourceIfNeeded(_ chatSource: ChatSource) throws -> Int64? {
    guard let db else { return nil }
    if let existingId = try getId(for: chatSource) {
      return existingId
    }

    return try db.run(chatSourcesTable.insert(chatIdColumn <- chatSource.id))
  }
}
