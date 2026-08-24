import AppKit
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate, NSUserNotificationCenterDelegate {
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        NSUserNotificationCenter.default.delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error {
                NSLog("Pinger notification authorization error: \(error.localizedDescription)")
                return
            }

            NSLog("Pinger notification authorization granted: \(granted)")
        }
    }

    func showTimerFinishedNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                NSLog("Pinger notifications are not authorized. Status: \(settings.authorizationStatus.rawValue)")
                self.deliverLegacyTimerFinishedNotification()
                return
            }

            self.deliverTimerFinishedNotification()
        }
    }

    private func deliverTimerFinishedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Pinger"
        content.body = "Timer finished. Starting again."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                NSLog("Pinger notification delivery error: \(error.localizedDescription)")
                self.deliverLegacyTimerFinishedNotification()
            }
        }
    }

    private func deliverLegacyTimerFinishedNotification() {
        DispatchQueue.main.async {
            let notification = NSUserNotification()
            notification.title = "Pinger"
            notification.informativeText = "Timer finished. Starting again."
            notification.soundName = NSUserNotificationDefaultSoundName
            NSUserNotificationCenter.default.deliver(notification)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(
        _ center: NSUserNotificationCenter,
        shouldPresent notification: NSUserNotification
    ) -> Bool {
        true
    }
}
