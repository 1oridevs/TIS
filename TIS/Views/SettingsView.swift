import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showingNotificationSettings = false
    @State private var dailyReminderTime = Date()
    @State private var enableDailyReminder = false
    @State private var enableShiftReminders = true
    @State private var showingExportOptions = false
    @State private var showingShiftReminders = false
    @State private var showingLocalizationSettings = false
    
    var body: some View {
        NavigationView {
            List {
                // Notifications Section
                Section(localizationManager.localizedString(for: "settings.notifications")) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                        Text(localizationManager.localizedString(for: "reminders.notification_status"))
                        Spacer()
                        if notificationManager.isAuthorized {
                            Text(localizationManager.localizedString(for: "reminders.enabled"))
                                .foregroundColor(.green)
                                .font(.caption)
                        } else {
                            Button(localizationManager.localizedString(for: "reminders.enable")) {
                                notificationManager.requestPermission()
                            }
                            .font(.caption)
                        }
                    }
                    
                    Toggle("Daily Reminders", isOn: $enableDailyReminder)
                        .onChange(of: enableDailyReminder) { _, enabled in
                            if enabled {
                                scheduleDailyReminder()
                            } else {
                                notificationManager.cancelNotification(withIdentifier: "daily-reminder")
                            }
                        }
                    
                    if enableDailyReminder {
                        DatePicker("Reminder Time", selection: $dailyReminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: dailyReminderTime) { _, _ in
                                scheduleDailyReminder()
                            }
                    }
                    
                    Toggle("Shift Reminders", isOn: $enableShiftReminders)
                    
                    Button(action: { showingShiftReminders = true }) {
                        HStack {
                            Image(systemName: "clock.badge.checkmark")
                                .foregroundColor(.blue)
                            Text(localizationManager.localizedString(for: "settings.manage_reminders"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                
                // Localization Section
                Section("Localization") {
                    Button(action: { showingLocalizationSettings = true }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                            Text("\(localizationManager.localizedString(for: "settings.language")) & \(localizationManager.localizedString(for: "settings.currency"))")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                
                // Data Management Section
                Section("Data Management") {
                    Button(action: { showingExportOptions = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Export Data")
                        }
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Clear All Data")
                        }
                    }
                    .foregroundColor(.red)
                }
                
                // App Information Section
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                }
                
                // About Section
                Section("About TIS") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TIS - Time is Money")
                            .font(.headline)
                        
                        Text("Track your work hours, calculate earnings, and manage your time effectively. Built with SwiftUI and Core Data for offline-first functionality.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView(shifts: [])
        }
        .sheet(isPresented: $showingShiftReminders) {
            ShiftRemindersView()
        }
        .sheet(isPresented: $showingLocalizationSettings) {
            LocalizationSettingsView()
        }
    }
    
    private func scheduleDailyReminder() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: dailyReminderTime)
        let minute = calendar.component(.minute, from: dailyReminderTime)
        
        notificationManager.scheduleDailyReminder(
            hour: hour,
            minute: minute,
            message: "Don't forget to track your time today! 💰"
        )
    }
}

#Preview {
    SettingsView()
}
