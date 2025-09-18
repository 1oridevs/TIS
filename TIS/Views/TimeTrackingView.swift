import SwiftUI
import CoreData

struct TimeTrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var timeTracker: TimeTracker
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)],
        animation: .default)
    private var jobs: FetchedResults<Job>
    
    @State private var selectedJob: Job?
    @State private var showingJobSelection = false
    @State private var shiftNotes = ""
    @State private var selectedShiftType = "Regular"
    @State private var showingAddShift = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Time Display
                    TimeDisplayView()
                    
                    // Job Selection
                    JobSelectionView()
                    
                    // Shift Type Display
                    ShiftTypeDisplayView()
                    
                    // Notes Section
                    NotesSectionView()
                    
                    // Control Buttons
                    ControlButtonsView()
                    
                    // Bottom padding to prevent interference with tab bar
                    Color.clear
                        .frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .navigationTitle("Time Tracking")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddShift = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
        .onAppear {
            timeTracker.setContext(viewContext)
        }
        .sheet(isPresented: $showingAddShift) {
            NavigationView {
                VStack(spacing: 20) {
                    Text("Add Manual Shift")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("This feature allows you to add past shifts manually.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("Job:")
                            Spacer()
                            Text("Select from your jobs")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Start Time:")
                            Spacer()
                            Text("Date & Time picker")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("End Time:")
                            Spacer()
                            Text("Date & Time picker")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Notes:")
                            Spacer()
                            Text("Optional")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button("Close") {
                        showingAddShift = false
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .padding()
                .navigationTitle("Add Shift")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingAddShift = false
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func TimeDisplayView() -> some View {
        VStack(spacing: 24) {
            // Main Timer Circle with Enhanced Design
            ZStack {
                // Outer glow ring
                Circle()
                    .fill(timeTracker.isTracking ? TISColors.successGradient : TISColors.primaryGradient)
                    .frame(width: 220, height: 220)
                    .blur(radius: 8)
                    .opacity(0.3)
                
                // Main circle
                Circle()
                    .fill(timeTracker.isTracking ? TISColors.successGradient : TISColors.cardGradient)
                    .frame(width: 200, height: 200)
                    .scaleEffect(timeTracker.isTracking ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: timeTracker.isTracking)
                
                // Inner content
                VStack(spacing: 12) {
                    // Status icon
                    Image(systemName: timeTracker.isTracking ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.8))
                        .scaleEffect(timeTracker.isTracking ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: timeTracker.isTracking)
                    
                    // Time display
                    if timeTracker.isTracking {
                        Text(formatTime(timeTracker.elapsedTime))
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .animation(.easeInOut(duration: 0.5), value: timeTracker.elapsedTime)
                    } else {
                        Text("00:00:00")
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Status text
                    Text(timeTracker.isTracking ? "TRACKING" : "READY")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(3)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.2))
                        )
                }
            }
            
            // Job info with enhanced design
            VStack(spacing: 12) {
                if timeTracker.isTracking {
                    HStack {
                        Image(systemName: "briefcase.fill")
                            .foregroundColor(TISColors.success)
                            .font(.title3)
                        
                        Text("Currently tracking:")
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                        
                        Text(timeTracker.currentShift?.job?.name ?? "Unknown")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(TISColors.primaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(TISColors.success.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(TISColors.success.opacity(0.3), lineWidth: 1)
                            )
                    )
                } else {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(TISColors.primary)
                            .font(.title3)
                        
                        Text("Select a job to start tracking")
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(TISColors.primary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(TISColors.primary.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(TISColors.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(TISColors.cardBorder.opacity(0.3), lineWidth: 1)
                )
        )
        .tisShadow(TISShadows.large)
    }
    
    @ViewBuilder
    private func JobSelectionView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "briefcase.fill")
                    .foregroundColor(TISColors.primary)
                    .font(.title3)
                
                Text("Job Selection")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(TISColors.primaryText)
                
                Spacer()
            }
            
            if timeTracker.isTracking {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(TISColors.success.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(TISColors.success)
                            .font(.title3)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(timeTracker.currentShift?.job?.name ?? "Unknown Job")
                            .font(.headline)
                            .foregroundColor(TISColors.primaryText)
                        
                        Text(String(format: "$%.2f/hour", timeTracker.currentShift?.job?.hourlyRate ?? 0))
                            .font(.subheadline)
                            .foregroundColor(TISColors.success)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "clock.fill")
                        .foregroundColor(TISColors.success)
                        .font(.title3)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(TISColors.success.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(TISColors.success.opacity(0.3), lineWidth: 2)
                        )
                )
            } else {
                Button(action: { showingJobSelection = true }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(TISColors.primary.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "plus")
                                .foregroundColor(TISColors.primary)
                                .font(.title3)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedJob?.name ?? "Select Job")
                                .font(.headline)
                                .foregroundColor(selectedJob == nil ? TISColors.secondaryText : TISColors.primaryText)
                            
                            if let job = selectedJob {
                                Text(String(format: "$%.2f/hour", job.hourlyRate))
                                    .font(.subheadline)
                                    .foregroundColor(TISColors.success)
                            } else {
                                Text("Choose your work position")
                                    .font(.subheadline)
                                    .foregroundColor(TISColors.secondaryText)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(TISColors.secondaryText)
                            .font(.caption)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(TISColors.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedJob == nil ? TISColors.cardBorder.opacity(0.5) : TISColors.primary.opacity(0.3), lineWidth: 2)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(isPresented: $showingJobSelection) {
            JobSelectionSheet(selectedJob: $selectedJob)
        }
    }
    
    @ViewBuilder
    private func ShiftTypeDisplayView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shift Type")
                .font(.headline)
            
            HStack {
                Image(systemName: shiftTypeIcon)
                    .foregroundColor(shiftTypeColor)
                
                Text(currentShiftType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if timeTracker.isTracking {
                    Text("Auto-detected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(shiftTypeColor.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    private var currentShiftType: String {
        if timeTracker.isTracking, let shift = timeTracker.currentShift {
            // Simple shift type detection based on duration
            let duration = calculateDurationInHours(for: shift)
            if duration > 8 {
                return "Overtime"
            } else if duration > 12 {
                return "Special Event"
            }
            return "Regular"
        }
        return "Regular"
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime else { return 0 }
        let endTime = shift.endTime ?? Date()
        return endTime.timeIntervalSince(startTime) / 3600
    }
    
    private var shiftTypeIcon: String {
        switch currentShiftType {
        case "Overtime":
            return "clock.badge.exclamationmark"
        case "Special Event":
            return "star.fill"
        default:
            return "clock"
        }
    }
    
    private var shiftTypeColor: Color {
        switch currentShiftType {
        case "Overtime":
            return .orange
        case "Special Event":
            return .purple
        default:
            return .blue
        }
    }
    
    @ViewBuilder
    private func NotesSectionView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes (Optional)")
                .font(.headline)
            
            TextField("Add notes about this shift...", text: $shiftNotes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
        }
    }
    
    @ViewBuilder
    private func ControlButtonsView() -> some View {
        VStack(spacing: 16) {
            if timeTracker.isTracking {
                // End Shift Button with Enhanced Design
                Button(action: endShift) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "stop.fill")
                                .font(.title3)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("End Shift")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text("Stop tracking time")
                                .font(.caption)
                                .opacity(0.8)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                    }
                    .foregroundColor(.white)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(TISColors.warningGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .tisShadow(TISShadows.medium)
                }
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.3), value: timeTracker.isTracking)
            } else {
                // Start Shift Button with Enhanced Design
                Button(action: startShift) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "play.fill")
                                .font(.title3)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Start Shift")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(selectedJob == nil ? "Select a job first" : "Begin tracking time")
                                .font(.caption)
                                .opacity(0.8)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                    }
                    .foregroundColor(.white)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(selectedJob == nil ? TISColors.secondaryText : TISColors.successGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .tisShadow(TISShadows.medium)
                }
                .disabled(selectedJob == nil)
                .opacity(selectedJob == nil ? 0.6 : 1.0)
                .scaleEffect(selectedJob == nil ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: selectedJob == nil)
            }
            
            // Manual Shift Button (only when not tracking and job selected)
            if !timeTracker.isTracking && selectedJob != nil {
                Button(action: {
                    showingAddShift = true
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(TISColors.primary.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(TISColors.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Add Manual Shift")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primary)
                            
                            Text("Add past work hours")
                                .font(.caption)
                                .foregroundColor(TISColors.secondaryText)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle")
                            .font(.title2)
                            .foregroundColor(TISColors.primary)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(TISColors.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(TISColors.primary.opacity(0.3), lineWidth: 2)
                            )
                    )
                    .tisShadow(TISShadows.small)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func startShift() {
        guard let job = selectedJob else { return }
        
        timeTracker.startTracking(for: job)
        
        // Set notes (shift type will be set automatically when ending)
        if let currentShift = timeTracker.currentShift {
            currentShift.notes = shiftNotes
        }
        
        try? viewContext.save()
    }
    
    private func endShift() {
        if let currentShift = timeTracker.currentShift {
            currentShift.notes = shiftNotes
        }
        
        timeTracker.endTracking()
        shiftNotes = ""
        selectedJob = nil
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 3600)) / 60
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct JobSelectionSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)],
        animation: .default)
    private var jobs: FetchedResults<Job>
    
    @Binding var selectedJob: Job?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(jobs, id: \.id) { job in
                    Button(action: {
                        selectedJob = job
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(job.name ?? "Unknown Job")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(String(format: "$%.2f/hour", job.hourlyRate))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedJob?.id == job.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Select Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TimeTrackingView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(TimeTracker())
}
