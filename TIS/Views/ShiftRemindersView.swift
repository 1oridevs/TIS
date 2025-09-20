import SwiftUI
import UserNotifications

struct ShiftRemindersView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationManager = NotificationManager()
    
    @State private var shiftStartReminder = true
    @State private var shiftEndReminder = true
    @State private var dailyReminder = false
    @State private var weeklySummary = false
    
    @State private var startReminderTime = Date()
    @State private var endReminderTime = Date()
    @State private var dailyReminderTime = Date()
    @State private var weeklyReminderTime = Date()
    
    @State private var showingPermissionAlert = false
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(TISColors.primaryGradient)
                                .frame(width: 80, height: 80)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
                            
                            Image(systemName: "bell.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Shift Reminders")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Text("Stay on track with smart notifications")
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Permission Status
                    PermissionStatusCard()
                    
                    // Shift Reminders
                    ShiftRemindersCard()
                    
                    // Daily Reminders
                    DailyRemindersCard()
                    
                    // Weekly Summary
                    WeeklySummaryCard()
                    
                    // Test Notifications
                    TestNotificationsCard()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(TISColors.background)
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable notifications in Settings to receive shift reminders.")
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = false
            }
        }
    }
}

struct PermissionStatusCard: View {
    @StateObject private var notificationManager = NotificationManager()
    @State private var permissionStatus: UNAuthorizationStatus = .notDetermined
    
    var body: some View {
        TISCard {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: permissionIcon)
                        .font(.title2)
                        .foregroundColor(permissionColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notification Status")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(TISColors.primaryText)
                        
                        Text(permissionMessage)
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    if permissionStatus != .authorized {
                        Button("Enable") {
                            requestPermission()
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(TISColors.primary)
                        .cornerRadius(8)
                    }
                }
                
                if permissionStatus == .authorized {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(TISColors.success)
                        
                        Text("You'll receive shift reminders and updates")
                            .font(.caption)
                            .foregroundColor(TISColors.secondaryText)
                        
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            checkPermissionStatus()
        }
    }
    
    private var permissionIcon: String {
        switch permissionStatus {
        case .authorized: return "checkmark.circle.fill"
        case .denied: return "xmark.circle.fill"
        case .notDetermined: return "questionmark.circle.fill"
        case .provisional: return "exclamationmark.circle.fill"
        case .ephemeral: return "exclamationmark.circle.fill"
        @unknown default: return "questionmark.circle.fill"
        }
    }
    
    private var permissionColor: Color {
        switch permissionStatus {
        case .authorized: return TISColors.success
        case .denied: return TISColors.error
        case .notDetermined: return TISColors.warning
        case .provisional: return TISColors.info
        case .ephemeral: return TISColors.info
        @unknown default: return TISColors.warning
        }
    }
    
    private var permissionMessage: String {
        switch permissionStatus {
        case .authorized: return "Notifications are enabled"
        case .denied: return "Notifications are disabled"
        case .notDetermined: return "Permission not requested"
        case .provisional: return "Provisional notifications enabled"
        case .ephemeral: return "Ephemeral notifications enabled"
        @unknown default: return "Unknown status"
        }
    }
    
    private func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                permissionStatus = settings.authorizationStatus
            }
        }
    }
    
    private func requestPermission() {
        notificationManager.requestPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    checkPermissionStatus()
                } else {
                    // Show alert to go to settings
                }
            }
        }
    }
}

struct ShiftRemindersCard: View {
    @State private var shiftStartReminder = true
    @State private var shiftEndReminder = true
    @State private var startReminderTime = Date()
    @State private var endReminderTime = Date()
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "clock.badge.checkmark")
                        .font(.title2)
                        .foregroundColor(TISColors.primary)
                    
                    Text("Shift Reminders")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                VStack(spacing: 16) {
                    // Start Shift Reminder
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Toggle("Start Shift Reminder", isOn: $shiftStartReminder)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(TISColors.primaryText)
                        }
                        
                        if shiftStartReminder {
                            HStack {
                                Text("Remind me at:")
                                    .font(.subheadline)
                                    .foregroundColor(TISColors.secondaryText)
                                
                                Spacer()
                                
                                DatePicker("", selection: $startReminderTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    Divider()
                    
                    // End Shift Reminder
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Toggle("End Shift Reminder", isOn: $shiftEndReminder)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(TISColors.primaryText)
                        }
                        
                        if shiftEndReminder {
                            HStack {
                                Text("Remind me at:")
                                    .font(.subheadline)
                                    .foregroundColor(TISColors.secondaryText)
                                
                                Spacer()
                                
                                DatePicker("", selection: $endReminderTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: shiftStartReminder)
        .animation(.easeInOut(duration: 0.3), value: shiftEndReminder)
    }
}

struct DailyRemindersCard: View {
    @State private var dailyReminder = false
    @State private var dailyReminderTime = Date()
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .font(.title2)
                        .foregroundColor(TISColors.warning)
                    
                    Text("Daily Reminders")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    HStack {
                        Toggle("Daily Work Reminder", isOn: $dailyReminder)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(TISColors.primaryText)
                    }
                    
                    if dailyReminder {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Remind me at:")
                                    .font(.subheadline)
                                    .foregroundColor(TISColors.secondaryText)
                                
                                Spacer()
                                
                                DatePicker("", selection: $dailyReminderTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            }
                            
                            Text("Get a daily reminder to start tracking your work")
                                .font(.caption)
                                .foregroundColor(TISColors.secondaryText)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: dailyReminder)
    }
}

struct WeeklySummaryCard: View {
    @State private var weeklySummary = false
    @State private var weeklyReminderTime = Date()
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundColor(TISColors.purple)
                    
                    Text("Weekly Summary")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    HStack {
                        Toggle("Weekly Earnings Summary", isOn: $weeklySummary)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(TISColors.primaryText)
                    }
                    
                    if weeklySummary {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Send summary on:")
                                    .font(.subheadline)
                                    .foregroundColor(TISColors.secondaryText)
                                
                                Spacer()
                                
                                Picker("Day", selection: $weeklyReminderTime) {
                                    Text("Sunday").tag(0)
                                    Text("Monday").tag(1)
                                    Text("Tuesday").tag(2)
                                    Text("Wednesday").tag(3)
                                    Text("Thursday").tag(4)
                                    Text("Friday").tag(5)
                                    Text("Saturday").tag(6)
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            Text("Get a weekly summary of your earnings and hours")
                                .font(.caption)
                                .foregroundColor(TISColors.secondaryText)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: weeklySummary)
    }
}

struct TestNotificationsCard: View {
    @StateObject private var notificationManager = NotificationManager()
    @State private var isSendingTest = false
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(TISColors.info)
                    
                    Text("Test Notifications")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    Text("Send a test notification to make sure everything is working")
                        .font(.subheadline)
                        .foregroundColor(TISColors.secondaryText)
                        .multilineTextAlignment(.leading)
                    
                    Button(action: sendTestNotification) {
                        HStack {
                            if isSendingTest {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .font(.subheadline)
                            }
                            
                            Text(isSendingTest ? "Sending..." : "Send Test Notification")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(TISColors.primary)
                        .cornerRadius(8)
                    }
                    .disabled(isSendingTest)
                }
            }
        }
    }
    
    private func sendTestNotification() {
        isSendingTest = true
        
        notificationManager.sendTestNotification { success in
            DispatchQueue.main.async {
                isSendingTest = false
                
                if success {
                    // Show success feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            }
        }
    }
}

#Preview {
    ShiftRemindersView()
}
