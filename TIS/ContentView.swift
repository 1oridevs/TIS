import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var timeTracker = TimeTracker()
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(localizationManager.localizedString(for: "nav.dashboard"))
                }
                .tag(0)
            
            TimeTrackingView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text(localizationManager.localizedString(for: "nav.time_tracking"))
                }
                .tag(1)
            
            JobsView()
                .tabItem {
                    Image(systemName: "briefcase.fill")
                    Text(localizationManager.localizedString(for: "nav.jobs"))
                }
                .tag(2)
            
            HistoryView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text(localizationManager.localizedString(for: "nav.history"))
                }
                .tag(3)
            
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text(localizationManager.localizedString(for: "nav.analytics"))
                }
                .tag(4)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text(localizationManager.localizedString(for: "nav.settings"))
                }
                .tag(5)
        }
        .environmentObject(timeTracker)
        .environmentObject(localizationManager)
        .accentColor(.blue)
        .environment(\.layoutDirection, localizationManager.currentLanguage.isRTL ? .rightToLeft : .leftToRight)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
