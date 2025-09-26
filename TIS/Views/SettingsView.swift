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
    @State private var showingClearDataSuccess = false
    @State private var showingDataImport = false
    
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
                            icon: "arrow.triangle.2.circlepath",
                            title: "Data Migration",
                            subtitle: "Migrate and validate data",
                            color: .purple
                        ) {
                            // Data migration functionality
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
                            icon: "square.and.arrow.down",
                            title: "Import Data",
                            subtitle: "Import from other apps",
                            color: .blue
                        ) {
                            showingDataImport = true
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
            .sheet(isPresented: $showingDataImport) {
                DataImportWrapperView()
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
            .alert("Data Cleared Successfully", isPresented: $showingClearDataSuccess) {
                Button("OK") { }
            } message: {
                Text("All your data has been permanently deleted. The app will now show empty states.")
            }
        }
    }
    
    private func clearAllData() {
        do {
            // Clear all Shifts
            let shiftFetchRequest: NSFetchRequest<NSFetchRequestResult> = Shift.fetchRequest()
            let shiftDeleteRequest = NSBatchDeleteRequest(fetchRequest: shiftFetchRequest)
            shiftDeleteRequest.resultType = .resultTypeObjectIDs
            let shiftResult = try viewContext.execute(shiftDeleteRequest) as? NSBatchDeleteResult
            let shiftObjectIDs = shiftResult?.result as? [NSManagedObjectID] ?? []
            
            // Clear all Jobs
            let jobFetchRequest: NSFetchRequest<NSFetchRequestResult> = Job.fetchRequest()
            let jobDeleteRequest = NSBatchDeleteRequest(fetchRequest: jobFetchRequest)
            jobDeleteRequest.resultType = .resultTypeObjectIDs
            let jobResult = try viewContext.execute(jobDeleteRequest) as? NSBatchDeleteResult
            let jobObjectIDs = jobResult?.result as? [NSManagedObjectID] ?? []
            
            // Clear all Bonuses
            let bonusFetchRequest: NSFetchRequest<NSFetchRequestResult> = Bonus.fetchRequest()
            let bonusDeleteRequest = NSBatchDeleteRequest(fetchRequest: bonusFetchRequest)
            bonusDeleteRequest.resultType = .resultTypeObjectIDs
            let bonusResult = try viewContext.execute(bonusDeleteRequest) as? NSBatchDeleteResult
            let bonusObjectIDs = bonusResult?.result as? [NSManagedObjectID] ?? []
            
            // Clear all Achievements
            let achievementFetchRequest: NSFetchRequest<NSFetchRequestResult> = Achievement.fetchRequest()
            let achievementDeleteRequest = NSBatchDeleteRequest(fetchRequest: achievementFetchRequest)
            achievementDeleteRequest.resultType = .resultTypeObjectIDs
            let achievementResult = try viewContext.execute(achievementDeleteRequest) as? NSBatchDeleteResult
            let achievementObjectIDs = achievementResult?.result as? [NSManagedObjectID] ?? []
            
            // Merge changes to update the context
            let changes = [NSDeletedObjectsKey: shiftObjectIDs + jobObjectIDs + bonusObjectIDs + achievementObjectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
            
            // Save the context
            try viewContext.save()
            
            // Reset UserDefaults for earnings goals and other settings
            UserDefaults.standard.removeObject(forKey: "earningsGoal")
            UserDefaults.standard.removeObject(forKey: "dailyEarningsGoal")
            UserDefaults.standard.removeObject(forKey: "weeklyEarningsGoal")
            UserDefaults.standard.removeObject(forKey: "monthlyEarningsGoal")
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
            UserDefaults.standard.removeObject(forKey: "achievementsUnlocked")
            UserDefaults.standard.removeObject(forKey: "totalEarnings")
            UserDefaults.standard.removeObject(forKey: "totalHours")
            UserDefaults.standard.removeObject(forKey: "totalShifts")
            UserDefaults.standard.removeObject(forKey: "lastBackupDate")
            UserDefaults.standard.removeObject(forKey: "backupCount")
            
            print("✅ All data cleared successfully")
            showingClearDataSuccess = true
            
        } catch {
            print("❌ Error clearing data: \(error)")
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

// MARK: - DataImportWrapperView

struct DataImportWrapperView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var selectedImportType: ImportType = .csv
    @State private var showingFilePicker = false
    @State private var isImporting = false
    @State private var importResult: ImportResult?
    @State private var showingResult = false
    @State private var selectedFileURL: URL?
    
    enum ImportType: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
        case toggl = "Toggl"
        
        var description: String {
            switch self {
            case .csv:
                return "Import from CSV file with jobs and shifts"
            case .json:
                return "Import from JSON backup file"
            case .toggl:
                return "Import from Toggl time tracking export"
            }
        }
        
        var icon: String {
            switch self {
            case .csv:
                return "tablecells"
            case .json:
                return "doc.text"
            case .toggl:
                return "clock.arrow.circlepath"
            }
        }
    }
    
    struct ImportResult {
        let importedJobs: Int
        let importedShifts: Int
        let errors: [String]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 40))
                        .foregroundColor(TISColors.primary)
                    
                    Text("Import Data")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Text("Import your existing time tracking data from other apps")
                        .font(.subheadline)
                        .foregroundColor(TISColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Import Type Selection
                VStack(spacing: 16) {
                    Text("Select Import Type")
                        .font(.headline)
                        .foregroundColor(TISColors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(ImportType.allCases, id: \.self) { type in
                        ImportTypeCard(
                            type: type,
                            isSelected: selectedImportType == type,
                            onTap: { selectedImportType = type }
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                // Progress Section
                if isImporting {
                    VStack(spacing: 12) {
                        Text("Importing data...")
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                            .multilineTextAlignment(.center)
                        
                        ProgressView()
                            .progressViewStyle(LinearProgressViewStyle(tint: TISColors.primary))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(TISColors.primary.opacity(0.05))
                    )
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Import Button
                VStack(spacing: 12) {
                    Button(action: startImport) {
                        HStack {
                            if isImporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "square.and.arrow.down")
                            }
                            Text(isImporting ? "Importing..." : "Select File to Import")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [TISColors.primary, TISColors.primary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: TISColors.primary.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .disabled(isImporting)
                    .opacity(isImporting ? 0.6 : 1.0)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(TISColors.secondaryText)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.commaSeparatedText, .json, .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedFileURL = url
                    performImport()
                }
            case .failure(let error):
                print("File picker error: \(error)")
            }
        }
        .alert("Import Result", isPresented: $showingResult) {
            Button("OK") { }
        } message: {
            if let result = importResult {
                Text("""
                Imported \(result.importedJobs) jobs and \(result.importedShifts) shifts.
                \(result.errors.isEmpty ? "No errors." : "\(result.errors.count) errors occurred.")
                """)
            }
        }
    }
    
    private func startImport() {
        showingFilePicker = true
    }
    
    private func performImport() {
        guard let fileURL = selectedFileURL else { return }
        
        isImporting = true
        
        // Simulate import process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isImporting = false
            
            // Mock result
            self.importResult = ImportResult(
                importedJobs: 3,
                importedShifts: 15,
                errors: []
            )
            self.showingResult = true
        }
    }
}

// MARK: - ImportTypeCard

struct ImportTypeCard: View {
    let type: DataImportWrapperView.ImportType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : TISColors.primary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? TISColors.primary : TISColors.primary.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : TISColors.primaryText)
                    
                    Text(type.description)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : TISColors.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? TISColors.primary : TISColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? TISColors.primary : TISColors.primary.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}