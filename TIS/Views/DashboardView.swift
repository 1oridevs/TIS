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
                VStack(spacing: 24) {
                    // Current Status Card
                    CurrentStatusCard()
                    
                    // Quick Actions
                    QuickActionsCard()
                    
                    // Jobs Overview
                    JobsOverviewCard()
                    
                    // Recent Activity
                    RecentActivityCard()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(TISColors.background)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddJob = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(TISColors.primary)
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
        TISCard(shadow: TISShadows.medium) {
            VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    Circle()
                        .fill(timeTracker.isTracking ? TISColors.successGradient : TISColors.cardGradient)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: timeTracker.isTracking ? "clock.fill" : "clock")
                        .font(.title2)
                        .foregroundColor(timeTracker.isTracking ? .white : TISColors.secondaryText)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(timeTracker.isTracking ? "Currently Working" : "Ready to Work")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    if timeTracker.isTracking {
                        Text("Tap to view details")
                            .font(.caption)
                            .foregroundColor(TISColors.secondaryText)
                    }
                }
                
                Spacer()
                
                if timeTracker.isTracking {
                    Circle()
                        .fill(TISColors.success)
                        .frame(width: 12, height: 12)
                        .scaleEffect(timeTracker.isTracking ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: timeTracker.isTracking)
                }
            }
                
                if timeTracker.isTracking {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Job:")
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                            Text(timeTracker.currentShift?.job?.name ?? "Unknown")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(TISColors.primaryText)
                        }
                        
                        HStack {
                            Text("Time:")
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                            Text(formatTime(timeTracker.elapsedTime))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(TISColors.primary)
                                .monospacedDigit()
                        }
                    }
                } else {
                    Text("Start tracking your time to see earnings")
                        .font(.subheadline)
                        .foregroundColor(TISColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            }
        }
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
        TISCard(shadow: TISShadows.medium) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(TISColors.primaryGradient)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "bolt.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    Text("Quick Actions")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                if timeTracker.isTracking {
                    TISButton("End Shift", icon: "stop.fill", color: TISColors.error) {
                        timeTracker.endTracking()
                    }
                } else {
                    if jobs.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "briefcase.badge.plus")
                                .font(.title)
                                .foregroundColor(TISColors.secondaryText)
                            
                            Text("Add a job to start tracking time")
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(jobs.prefix(4), id: \.id) { job in
                                Button(action: { timeTracker.startTracking(for: job) }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "play.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                        
                                        Text(job.name ?? "Job")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(TISColors.success)
                                    .cornerRadius(12)
                                    .tisShadow(TISShadows.small)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
        }
    }
}

struct JobsOverviewCard: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)],
        animation: .default)
    private var jobs: FetchedResults<Job>
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Jobs Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(TISColors.primaryText)
                
                if jobs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "briefcase")
                            .font(.title)
                            .foregroundColor(TISColors.secondaryText)
                        
                        Text("No jobs added yet")
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(jobs.prefix(4), id: \.id) { job in
                            TISStatCard(
                                title: job.name ?? "Unknown",
                                value: String(format: "$%.0f", calculateTotalEarnings(for: job)),
                                icon: "briefcase.fill",
                                color: TISColors.primary
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateTotalEarnings(for job: Job) -> Double {
        guard let shifts = job.shifts?.allObjects as? [Shift] else { return 0 }
        return shifts.reduce(0.0) { total, shift in
            total + calculateTotalEarnings(for: shift)
        }
    }
    
    private func calculateTotalEarnings(for shift: Shift) -> Double {
        let duration = calculateDurationInHours(for: shift)
        let baseEarnings = duration * (shift.job?.hourlyRate ?? 0.0)
        let bonusAmount = shift.bonusAmount 
        return baseEarnings + bonusAmount
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime else { return 0 }
        let endTime = shift.endTime ?? Date()
        return endTime.timeIntervalSince(startTime) / 3600
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
                Text(String(format: "$%.2f", calculateTotalEarnings(for: job)))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(String(format: "%.1fh", calculateTotalHours(for: job)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Helper Functions
    
    private func calculateTotalEarnings(for job: Job) -> Double {
        guard let shifts = job.shifts?.allObjects as? [Shift] else { return 0 }
        return shifts.reduce(0.0) { total, shift in
            total + calculateTotalEarnings(for: shift)
        }
    }
    
    private func calculateTotalHours(for job: Job) -> Double {
        guard let shifts = job.shifts?.allObjects as? [Shift] else { return 0 }
        return shifts.reduce(0.0) { total, shift in
            total + calculateDurationInHours(for: shift)
        }
    }
    
    private func calculateTotalEarnings(for shift: Shift) -> Double {
        let duration = calculateDurationInHours(for: shift)
        let baseEarnings = duration * (shift.job?.hourlyRate ?? 0.0)
        let bonusAmount = shift.bonusAmount 
        return baseEarnings + bonusAmount
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime else { return 0 }
        let endTime = shift.endTime ?? Date()
        return endTime.timeIntervalSince(startTime) / 3600
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
    
    // MARK: - Helper Functions
    
    private func calculateTotalEarnings(for shift: Shift) -> Double {
        let duration = calculateDurationInHours(for: shift)
        let baseEarnings = duration * (shift.job?.hourlyRate ?? 0.0)
        let bonusAmount = shift.bonusAmount 
        return baseEarnings + bonusAmount
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime else { return 0 }
        let endTime = shift.endTime ?? Date()
        return endTime.timeIntervalSince(startTime) / 3600
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
                Text(String(format: "$%.2f", calculateTotalEarnings(for: shift)))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(String(format: "%.1fh", calculateDurationInHours(for: shift)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Helper Functions
    
    private func calculateTotalEarnings(for job: Job) -> Double {
        guard let shifts = job.shifts?.allObjects as? [Shift] else { return 0 }
        return shifts.reduce(0.0) { total, shift in
            total + calculateTotalEarnings(for: shift)
        }
    }
    
    private func calculateTotalHours(for job: Job) -> Double {
        guard let shifts = job.shifts?.allObjects as? [Shift] else { return 0 }
        return shifts.reduce(0.0) { total, shift in
            total + calculateDurationInHours(for: shift)
        }
    }
    
    private func calculateTotalEarnings(for shift: Shift) -> Double {
        let duration = calculateDurationInHours(for: shift)
        let baseEarnings = duration * (shift.job?.hourlyRate ?? 0.0)
        let bonusAmount = shift.bonusAmount 
        return baseEarnings + bonusAmount
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime else { return 0 }
        let endTime = shift.endTime ?? Date()
        return endTime.timeIntervalSince(startTime) / 3600
    }
}

#Preview {
    DashboardView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(TimeTracker())
}
