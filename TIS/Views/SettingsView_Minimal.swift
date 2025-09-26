import SwiftUI
import UserNotifications

struct SettingsView_Backup: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section("Test") {
                    Text("Test Content")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView_Backup()
}
