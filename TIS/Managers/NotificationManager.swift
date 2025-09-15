import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleShiftReminder(afterHours: Double, message: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "TIS - Shift Reminder"
        content.body = message
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: afterHours * 3600, repeats: false)
        let request = UNNotificationRequest(identifier: "shift-reminder-\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleEndShiftReminder() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "TIS - Don't Forget!"
        content.body = "You're still tracking time. Remember to end your shift when you're done."
        content.sound = .default
        
        // Remind after 8 hours
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 8 * 3600, repeats: false)
        let request = UNNotificationRequest(identifier: "end-shift-reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleDailyReminder(hour: Int, minute: Int, message: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "TIS - Daily Reminder"
        content.body = message
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
