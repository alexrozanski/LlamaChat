//
//  MessagesTableView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 20/04/2023.
//

import SwiftUI

struct MessageView: View {
  @ObservedObject var viewModel: ObservableMessageViewModel
  let availableWidth: Double?

  var body: some View {
    if let staticMessageViewModel: StaticMessageViewModel = viewModel.get() {
      MessageBubbleView(sender: staticMessageViewModel.sender, style: .regular, isError: staticMessageViewModel.isError, availableWidth: availableWidth.map { $0 * 0.8 }) {
        Text(staticMessageViewModel.content)
          .textSelectionEnabled(viewModel.canCopyContents)
      }
    } else if let generatedMessageViewModel: GeneratedMessageViewModel = viewModel.get() {
      GeneratedMessageView(viewModel: generatedMessageViewModel, availableWidth: availableWidth.map { $0 * 0.8 })
    } else if let clearedContextMessageViewModel: ClearedContextMessageViewModel = viewModel.get() {
      ClearedContextMessageView(viewModel: clearedContextMessageViewModel)
    } else {
      #if DEBUG
      Text("Missing row view for `\(String(describing: type(of: viewModel.getUnderlyingViewModel())))`")
        .padding()
      #else
      EmptyView()
      #endif
    }
  }
}

fileprivate struct HostingContainerView: View {
  var viewModel: ObservableMessageViewModel?
  var availableWidth: Double?

  var body: some View {
    if let viewModel {
      MessageView(viewModel: viewModel, availableWidth: availableWidth)
    }
  }
}

class MessagesTableCellView: NSTableCellView {
  var viewModel: ObservableMessageViewModel? = nil {
    didSet {
      updateHostingView()
    }
  }

  private lazy var hostingView = NSHostingView(rootView: HostingContainerView())
  private var frameDidChangeNotificationHandle: NSObjectProtocol?

  init(viewModel: ObservableMessageViewModel) {
    self.viewModel = viewModel

    super.init(frame: .zero)

    hostingView.rootView = HostingContainerView(viewModel: viewModel)
    addSubview(hostingView)
    hostingView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      hostingView.topAnchor.constraint(equalTo: topAnchor),
      hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
      hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
      hostingView.leadingAnchor.constraint(equalTo: leadingAnchor)
    ])

    postsFrameChangedNotifications = true
    frameDidChangeNotificationHandle = NotificationCenter.default.addObserver(
      forName: NSView.frameDidChangeNotification,
      object: self,
      queue: .main,
      using: { [weak self] _ in
        self?.updateHostingView()
      }
    )
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    hostingView.rootView = HostingContainerView()
  }

  private func updateHostingView() {
    hostingView.rootView = HostingContainerView(viewModel: viewModel, availableWidth: frame.width)
  }
}

// Wraps an NSTableView for more control over layout, scrolling etc than using a LazyVStack.
struct MessagesTableView: NSViewRepresentable {
  var messages: [ObservableMessageViewModel]

  init(messages: [ObservableMessageViewModel]) {
    self.messages = messages
  }

  func makeNSView(context: Context) -> NSScrollView {
    let scrollView = NSScrollView()
    scrollView.backgroundColor = .clear
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = false
    scrollView.autohidesScrollers = true

    let tableView = NSTableView()
    tableView.headerView = nil
    tableView.usesAutomaticRowHeights = true
    tableView.backgroundColor = .clear
    tableView.intercellSpacing = NSSize(width: 0, height: 12)

    let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Messages"))
    column.title = ""
    tableView.addTableColumn(column)

    tableView.dataSource = context.coordinator
    tableView.delegate = context.coordinator

    scrollView.documentView = tableView

    context.coordinator.tableView = tableView
    context.coordinator.lastRows = messages

    tableView.reloadData()
    tableView.scrollToEndOfDocument(nil)

    return scrollView
  }

  func updateNSView(_ nsView: NSScrollView, context: Context) {
    context.coordinator.parent = self

    if let tableView = context.coordinator.tableView {
      let diff = messages.difference(from: context.coordinator.lastRows)

      var rowsInserted = false
      tableView.beginUpdates()
      for change in diff {
        switch change {
        case let .insert(offset, _, _):
          tableView.insertRows(at: IndexSet(integer: offset), withAnimation: .slideDown)
          rowsInserted = true
        case let .remove(offset, _, _):
          tableView.removeRows(at: IndexSet(integer: offset))
        }
      }
      tableView.endUpdates()

      if rowsInserted {
        tableView.scrollToEndOfDocument(nil)
      }
    }

    context.coordinator.lastRows = messages
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }

  class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    private var frameDidChangeNotificationHandle: NSObjectProtocol?
    private var lastTableViewFrame: NSRect?

    var tableView: NSTableView? {
      didSet {
        if let tableView {
          lastTableViewFrame = tableView.frame
          tableView.postsBoundsChangedNotifications = true
          frameDidChangeNotificationHandle = NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification, object: tableView, queue: .main, using: { [weak self] _ in
            self?.tableViewFrameDidChange()
          })
        }
      }
    }
    var parent: MessagesTableView
    var lastRows: [ObservableMessageViewModel] = []

    init(_ parent: MessagesTableView) {
      self.parent = parent
    }

    func tableViewFrameDidChange() {
      guard let tableView else { return }

      // If we were scrolled to the end before the table frame change, scroll to the end now.
      if lastTableViewFrame?.maxY == tableView.visibleRect.maxY {
        tableView.scrollToEndOfDocument(nil)
      }
      lastTableViewFrame = tableView.frame
    }

    // MARK: - NSTableView Delegate/DataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
      return parent.messages.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
      return parent.messages[row]
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
      let identifier = NSUserInterfaceItemIdentifier("messageTableCellView")
      let cellView: MessagesTableCellView?
      let viewModel = parent.messages[row]

      if let reusedCellView = tableView.makeView(withIdentifier: identifier, owner: self) as? MessagesTableCellView {
        reusedCellView.viewModel = viewModel
        cellView = reusedCellView
      } else {
        let newCellView = MessagesTableCellView(viewModel: viewModel)
        newCellView.identifier = identifier
        cellView = newCellView
      }

      return cellView
    }

    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
      rowView.translatesAutoresizingMaskIntoConstraints = false
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
      return false
    }
  }
}
