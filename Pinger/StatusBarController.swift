import AppKit
import Combine
import SwiftUI

@MainActor
final class StatusBarController: NSObject {
    private let timerManager: TimerManager
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private var cancellables = Set<AnyCancellable>()

    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()

        super.init()

        configureStatusItem()
        configurePopover()
        bindTimer()
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else {
            return
        }

        button.title = timerManager.formattedRemainingTime()
        button.action = #selector(togglePopover)
        button.target = self
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 210, height: 164)

        let hostingController = NSHostingController(rootView: SettingsView(timerManager: timerManager))
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        popover.contentViewController = hostingController
    }

    private func bindTimer() {
        timerManager.$remainingSeconds
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.statusItem.button?.title = self?.timerManager.formattedRemainingTime() ?? "--:--"
            }
            .store(in: &cancellables)
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else {
            return
        }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
