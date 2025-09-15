import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var timeTracker = TimeTracker()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            TimeTrackingView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("Time Tracking")
                }
                .tag(1)
            
            JobsView()
                .tabItem {
                    Image(systemName: "briefcase.fill")
                    Text("Jobs")
                }
                .tag(2)
            
            HistoryView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("History")
                }
                .tag(3)
        }
        .environmentObject(timeTracker)
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
