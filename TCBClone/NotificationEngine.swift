import UIKit
import UserNotifications

// MARK: - Notification engine
//
// Local notifications render exactly like remote pushes on iOS.
// Same banner, same lock screen card, same Notification Center row,
// same icon, same app name. The only difference is invisible.
//
final class NotificationEngine: NSObject {

    static let shared = NotificationEngine()

    private let center = UNUserNotificationCenter.current()
    private(set) var authorized = false

    // MARK: Bootstrap

    func bootstrap() {
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async { self?.authorized = granted }
        }
    }

    // MARK: Fire

    /// Bắn notification sau `after` giây (mặc định 1s).
    func fire(_ model: BankNotification,
              after: TimeInterval = 1.0,
              completion: ((Error?) -> Void)? = nil) {

        let content = buildContent(model)

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(0.5, after),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            DispatchQueue.main.async { completion?(error) }
        }
    }

    /// Bắn đúng thời điểm trong tương lai.
    func fire(_ model: BankNotification,
              at date: Date,
              completion: ((Error?) -> Void)? = nil) {

        let content = buildContent(model)

        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            DispatchQueue.main.async { completion?(error) }
        }
    }

    // MARK: Content

    private func buildContent(_ model: BankNotification) -> UNMutableNotificationContent {
        let c = UNMutableNotificationContent()
        c.title = model.title
        if let sub = model.subtitle, !sub.isEmpty { c.subtitle = sub }
        c.body = model.body

        if model.playSound {
            c.sound = .default
        }

        if model.groupAsThread {
            // Gom nhóm như notification thật của app ngân hàng.
            c.threadIdentifier = "vn.techcombank.transaction"
        }

        c.categoryIdentifier = "TCB_TRANSACTION"

        if #available(iOS 15.0, *) {
            c.interruptionLevel = model.timeSensitive ? .timeSensitive : .active
            c.relevanceScore = model.direction == .credit ? 1.0 : 0.5
        }

        if model.bumpBadge {
            c.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        }

        return c
    }

    // MARK: Housekeeping

    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        center.removeAllDeliveredNotifications()
    }

    func registerCategory() {
        let open = UNNotificationAction(identifier: "OPEN", title: "Mở", options: [.foreground])
        let cat = UNNotificationCategory(
            identifier: "TCB_TRANSACTION",
            actions: [open],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([cat])
    }
}

// MARK: - Foreground presentation
extension NotificationEngine: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                    @escaping (UNNotificationPresentationOptions) -> Void) {
        // Hiện banner + sound cả khi app đang mở, giống push thật.
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
