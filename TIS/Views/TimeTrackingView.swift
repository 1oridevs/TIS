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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
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
                
                Spacer()
            }
            .padding()
            .navigationTitle("Time Tracking")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            timeTracker.setContext(viewContext)
        }
    }
    
    @ViewBuilder
    private func TimeDisplayView() -> some View {
        VStack(spacing: 16) {
            if timeTracker.isTracking {
                Text(formatTime(timeTracker.elapsedTime))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                
                Text("Currently tracking: \(timeTracker.currentShift?.job?.name ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("00:00:00")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                
                Text("Select a job to start tracking")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func JobSelectionView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Job")
                .font(.headline)
            
            if timeTracker.isTracking {
                HStack {
                    Image(systemName: "briefcase.fill")
                        .foregroundColor(.blue)
                    Text(timeTracker.currentShift?.job?.name ?? "Unknown Job")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "$%.2f/hour", timeTracker.currentShift?.job?.hourlyRate ?? 0))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else {
                Button(action: { showingJobSelection = true }) {
                    HStack {
                        Image(systemName: "briefcase")
                        Text(selectedJob?.name ?? "Select Job")
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .foregroundColor(.primary)
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
                Button(action: endShift) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("End Shift")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            } else {
                Button(action: startShift) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Shift")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedJob != nil ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(selectedJob == nil)
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
