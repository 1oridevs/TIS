import SwiftUI
import UserNotifications
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    @State private var showingNotificationSettings = false
    @State private var dailyReminderTime = Date()
    @State private var enableDailyReminder = false
    @State private var enableShiftReminders = true
    @State private var showingExportOptions = false
    @State private var showingShiftReminders = false
    @State private var showingLocalizationSettings = false
    @State private var showingBackupSettings = false
    @State private var showingBulkOperations = false
    @State private var showingClearDataConfirmation = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background
                LinearGradient(
                    colors: [
                        TISColors.background,
                        TISColors.background.opacity(0.95),
                        TISColors.primary.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                List {
                    // Profile Section
                    Section {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(TISColors.primary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TIS User")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Time is Money")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Version 1.0.0")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Profile")
                    }
                    
                    // Data Management Section
                    Section {
                        SettingsRowView(
                            icon: "icloud.and.arrow.up",
                            title: "Data Backup",
                            subtitle: "Backup and restore your data",
                            color: .blue
                        ) {
                            showingBackupSettings = true
                        }
                        
                        SettingsRowView(
                            icon: "square.and.arrow.up",
                            title: "Export Data",
                            subtitle: "Export shifts and earnings",
                            color: .green
                        ) {
                            showingExportOptions = true
                        }
                        
                        SettingsRowView(
                            icon: "trash",
                            title: "Bulk Operations",
                            subtitle: "Delete multiple items",
                            color: .orange
                        ) {
                            showingBulkOperations = true
                        }
                        
                        SettingsRowView(
                            icon: "trash.circle",
                            title: "Clear All Data",
                            subtitle: "Delete all data permanently",
                            color: .red
                        ) {
                            showingClearDataConfirmation = true
                        }
                    } header: {
                        Text("Data Management")
                    }
                    
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
                        
                        Toggle("Shift Reminders", isOn: $enableShiftReminders)
                            .onChange(of: enableShiftReminders) { _, enabled in
                                if enabled {
                                    // Enable shift reminders
                                } else {
                                    // Disable shift reminders
                                }
                            }
                        
                        if enableDailyReminder {
                            DatePicker("Reminder Time", selection: $dailyReminderTime, displayedComponents: .hourAndMinute)
                                .onChange(of: dailyReminderTime) { _, _ in
                                    scheduleDailyReminder()
                                }
                        }
                    }
                    
                    // Localization Section
                    Section("Language & Currency") {
                        SettingsRowView(
                            icon: "globe",
                            title: "Language",
                            subtitle: localizationManager.currentLanguage == .english ? "English" : "עברית",
                            color: .purple
                        ) {
                            showingLocalizationSettings = true
                        }
                        
                        SettingsRowView(
                            icon: "dollarsign.circle",
                            title: "Currency",
                            subtitle: localizationManager.currentCurrency.rawValue,
                            color: .green
                        ) {
                            showingLocalizationSettings = true
                        }
                    }
                    
                    // App Information Section
                    Section("App Information") {
                        SettingsRowView(
                            icon: "info.circle",
                            title: "About TIS",
                            subtitle: "Version 1.0.0 • Build 1",
                            color: .blue
                        ) {
                            showingAbout = true
                        }
                        
                        SettingsRowView(
                            icon: "doc.text",
                            title: "Privacy Policy",
                            subtitle: "How we protect your data",
                            color: .gray
                        ) {
                            if let url = URL(string: "https://example.com/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        SettingsRowView(
                            icon: "doc.plaintext",
                            title: "Terms of Service",
                            subtitle: "Usage terms and conditions",
                            color: .gray
                        ) {
                            if let url = URL(string: "https://example.com/terms") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    
                    // Support Section
                    Section("Support") {
                        SettingsRowView(
                            icon: "envelope",
                            title: "Contact Support",
                            subtitle: "Get help with TIS",
                            color: .blue
                        ) {
                            if let url = URL(string: "mailto:support@tisapp.com") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        SettingsRowView(
                            icon: "star",
                            title: "Rate TIS",
                            subtitle: "Share your feedback",
                            color: .yellow
                        ) {
                            // Rate app functionality
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
            }
            .navigationTitle(localizationManager.localizedString(for: "settings.title"))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingExportOptions) {
                ExportOptionsView(shifts: [])
            }
            .sheet(isPresented: $showingShiftReminders) {
                ShiftRemindersView()
            }
            .sheet(isPresented: $showingLocalizationSettings) {
                LocalizationSettingsView()
            }
            .sheet(isPresented: $showingBackupSettings) {
                Text("Backup Settings - Coming Soon")
            }
            .sheet(isPresented: $showingBulkOperations) {
                Text("Bulk Operations - Coming Soon")
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .alert("Clear All Data", isPresented: $showingClearDataConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete All Data", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all your shifts, jobs, and settings. This action cannot be undone.")
            }
        }
    }
    
    private func clearAllData() {
        // Clear all Core Data entities
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shift")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let jobFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Job")
        let jobDeleteRequest = NSBatchDeleteRequest(fetchRequest: jobFetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.execute(jobDeleteRequest)
            try viewContext.save()
        } catch {
            print("Error clearing data: \(error)")
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

// MARK: - SettingsRowView Component

struct SettingsRowView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - AboutView

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon and Title
                    VStack(spacing: 16) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 80))
                            .foregroundColor(TISColors.primary)
                            .background(
                                Circle()
                                    .fill(TISColors.primary.opacity(0.1))
                                    .frame(width: 120, height: 120)
                            )
                        
                        VStack(spacing: 8) {
                            Text("TIS")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(TISColors.primary)
                            
                            Text("Time is Money")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Text("Version 1.0.0")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About TIS")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("TIS is a comprehensive time tracking application designed to help you manage your work hours, calculate earnings, and optimize your productivity. Built with SwiftUI and Core Data for offline-first functionality.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                    }
                    .padding(.horizontal)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Key Features")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "clock", title: "Time Tracking", description: "Track work hours with precision")
                            FeatureRow(icon: "dollarsign.circle", title: "Earnings Calculation", description: "Automatic earnings and overtime calculations")
                            FeatureRow(icon: "chart.bar", title: "Analytics", description: "Detailed insights and reporting")
                            FeatureRow(icon: "globe", title: "Multi-language", description: "English and Hebrew support")
                            FeatureRow(icon: "bell", title: "Notifications", description: "Smart reminders and alerts")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Developer Info
                    VStack(spacing: 8) {
                        Text("Developed by")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("1oridevs (Ori Cohen)")
                            .font(.headline)
                            .foregroundColor(TISColors.primary)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(TISColors.primary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}