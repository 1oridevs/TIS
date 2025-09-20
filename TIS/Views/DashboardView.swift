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
                LazyVStack(spacing: 24) {
                    // Welcome Header
                    WelcomeHeaderCard()
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                    
                    // Current Status Card
                    CurrentStatusCard()
                        .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .opacity))
                    
                    // Quick Actions
                    QuickActionsCard()
                        .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .opacity))
                    
                    // Jobs Overview
                    JobsOverviewCard()
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                    
                    // Recent Activity
                    RecentActivityCard()
                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100) // Extra padding for tab bar
            }
            .background(
                LinearGradient(
                    colors: [TISColors.background, TISColors.background.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showingAddJob = true 
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(TISColors.primary)
                            .scaleEffect(showingAddJob ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingAddJob)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddJob) {
            AddJobView()
        }
    }
}

struct WelcomeHeaderCard: View {
    @State private var currentTime = Date()
    @State private var greeting = ""
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TISCard {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(greeting)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(TISColors.primaryText)
                        
                        Text("Ready to track your time?")
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(currentTime, style: .time)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(TISColors.primary)
                        
                        Text(currentTime, style: .date)
                            .font(.caption)
                            .foregroundColor(TISColors.secondaryText)
                    }
                }
                
                // Motivational quote or tip
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(TISColors.warning)
                        .font(.caption)
                    
                    Text("💡 Tip: Start tracking as soon as you begin work for accurate records!")
                        .font(.caption)
                        .foregroundColor(TISColors.secondaryText)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
            updateGreeting()
        }
        .onAppear {
            updateGreeting()
        }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: currentTime)
        
        switch hour {
        case 5..<12:
            greeting = "Good Morning"
        case 12..<17:
            greeting = "Good Afternoon"
        case 17..<22:
            greeting = "Good Evening"
        default:
            greeting = "Good Night"
        }
    }
}

struct CurrentStatusCard: View {
    @EnvironmentObject private var timeTracker: TimeTracker
    @State private var pulseAnimation = false
    
    var body: some View {
        TISCard(shadow: TISShadows.medium) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    ZStack {
                        // Pulsing background for active tracking
                        if timeTracker.isTracking {
                            Circle()
                                .fill(TISColors.success.opacity(0.3))
                                .frame(width: 70, height: 70)
                                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                        }
                        
                        Circle()
                            .fill(timeTracker.isTracking ? TISColors.successGradient : TISColors.cardGradient)
                            .frame(width: 50, height: 50)
                            .scaleEffect(timeTracker.isTracking ? 1.1 : 1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: timeTracker.isTracking)
                        
                        Image(systemName: timeTracker.isTracking ? "clock.fill" : "clock")
                            .font(.title2)
                            .foregroundColor(timeTracker.isTracking ? .white : TISColors.secondaryText)
                            .scaleEffect(timeTracker.isTracking ? 1.1 : 1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: timeTracker.isTracking)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(timeTracker.isTracking ? "Currently Working" : "Ready to Work")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(TISColors.primaryText)
                            .animation(.easeInOut(duration: 0.3), value: timeTracker.isTracking)
                        
                        if timeTracker.isTracking {
                            Text("Tap to view details")
                                .font(.caption)
                                .foregroundColor(TISColors.secondaryText)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        } else {
                            Text("Start tracking your work")
                                .font(.caption)
                                .foregroundColor(TISColors.secondaryText)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    Spacer()
                    
                    if timeTracker.isTracking {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(TISColors.success)
                                .frame(width: 12, height: 12)
                                .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseAnimation)
                            
                            Text("LIVE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(TISColors.success)
                        }
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
        .onAppear {
            if timeTracker.isTracking {
                pulseAnimation = true
            }
        }
        .onChange(of: timeTracker.isTracking) { oldValue, isTracking in
            if isTracking {
                pulseAnimation = true
            } else {
                pulseAnimation = false
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
    
    @State private var buttonScale: CGFloat = 1.0
    @State private var showJobSelection = false
    
    var body: some View {
        TISCard(shadow: TISShadows.medium) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(TISColors.primaryGradient)
                            .frame(width: 40, height: 40)
                            .scaleEffect(buttonScale)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: buttonScale)
                        
                        Image(systemName: "bolt.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    Text("Quick Actions")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                    
                    if !jobs.isEmpty {
                        Text("\(jobs.count) job\(jobs.count == 1 ? "" : "s")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(TISColors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(TISColors.primary.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                if timeTracker.isTracking {
                    VStack(spacing: 12) {
                        TISButton("End Shift", icon: "stop.fill", color: TISColors.error) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                timeTracker.endTracking()
                            }
                        }
                        .scaleEffect(buttonScale)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                buttonScale = 0.95
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    buttonScale = 1.0
                                }
                            }
                        }
                        
                        Text("Tap to stop tracking and save your work")
                            .font(.caption)
                            .foregroundColor(TISColors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    if jobs.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "briefcase.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(TISColors.primary)
                                .scaleEffect(buttonScale)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: buttonScale)
                            
                            Text("Add a job to start tracking time")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(TISColors.primaryText)
                                .multilineTextAlignment(.center)
                            
                            Text("Create your first job to begin tracking your work hours and earnings")
                                .font(.caption)
                                .foregroundColor(TISColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .onAppear {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                                buttonScale = 1.1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                                    buttonScale = 1.0
                                }
                            }
                        }
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
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(TISColors.primary.opacity(0.1))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "briefcase.fill")
                                .font(.title2)
                                .foregroundColor(TISColors.primary)
                        }
                        
                        VStack(spacing: 8) {
                            Text("No jobs added yet")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Text("Add your first job to start tracking time and earnings")
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            // This will be handled by the parent view
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Your First Job")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(TISColors.primaryGradient)
                            .cornerRadius(20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
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
