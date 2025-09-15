import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var timeTracker: TimeTracker
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.createdAt, ascending: false)],
        animation: .default)
    private var jobs: FetchedResults<Job>
    
    @State private var showingAddJob = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Status Card
                    CurrentStatusCard()
                    
                    // Quick Actions
                    QuickActionsCard()
                    
                    // Jobs Overview
                    JobsOverviewCard()
                    
                    // Recent Activity
                    RecentActivityCard()
                }
                .padding()
            }
            .navigationTitle("TIS Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddJob = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddJob) {
            AddJobView()
        }
    }
}

struct CurrentStatusCard: View {
    @EnvironmentObject private var timeTracker: TimeTracker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: timeTracker.isTracking ? "clock.fill" : "clock")
                    .foregroundColor(timeTracker.isTracking ? .green : .gray)
                Text(timeTracker.isTracking ? "Currently Working" : "Not Working")
                    .font(.headline)
                Spacer()
            }
            
            if timeTracker.isTracking {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Job: \(timeTracker.currentShift?.job?.name ?? "Unknown")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Time: \(formatTime(timeTracker.elapsedTime))")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            } else {
                Text("Start tracking your time to see earnings")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 3600)) / 60
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct QuickActionsCard: View {
    @EnvironmentObject private var timeTracker: TimeTracker
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)],
        animation: .default)
    private var jobs: FetchedResults<Job>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            if timeTracker.isTracking {
                Button(action: { timeTracker.endTracking() }) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("End Shift")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else {
                if jobs.isEmpty {
                    Text("Add a job to start tracking time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(jobs, id: \.id) { job in
                        Button(action: { timeTracker.startTracking(for: job) }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start \(job.name ?? "Job")")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct JobsOverviewCard: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)],
        animation: .default)
    private var jobs: FetchedResults<Job>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Jobs Overview")
                .font(.headline)
            
            if jobs.isEmpty {
                Text("No jobs added yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(jobs, id: \.id) { job in
                    JobRowView(job: job)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct JobRowView: View {
    let job: Job
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(job.name ?? "Unknown Job")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(String(format: "$%.2f/hour", job.hourlyRate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", job.totalEarnings))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(String(format: "%.1fh", job.totalHoursWorked))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RecentActivityCard: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Shift.startTime, ascending: false)],
        predicate: NSPredicate(format: "isActive == NO"),
        animation: .default)
    private var recentShifts: FetchedResults<Shift>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
            
            if recentShifts.isEmpty {
                Text("No recent activity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(Array(recentShifts.prefix(3)), id: \.id) { shift in
                    ShiftRowView(shift: shift)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ShiftRowView: View {
    let shift: Shift
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(shift.job?.name ?? "Unknown Job")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let startTime = shift.startTime {
                    Text(startTime, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", shift.totalEarnings))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(String(format: "%.1fh", shift.durationInHours))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DashboardView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(TimeTracker())
}
