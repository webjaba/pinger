import AppKit
import UserNotifications

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let timerManager = TimerManager()
    private let notificationManager = NotificationManager()
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        notificationManager.requestAuthorization()
        timerManager.onTimerFinished = { [notificationManager] in
            notificationManager.showTimerFinishedNotification()
        }

        statusBarController = StatusBarController(timerManager: timerManager)
        timerManager.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        timerManager.stop()
    }
}
