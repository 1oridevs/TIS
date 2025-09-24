import SwiftUI
import CoreData

struct TimeTrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var timeTracker: TimeTracker
    @EnvironmentObject private var localizationManager: LocalizationManager
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)],
        animation: .default)
    private var jobs: FetchedResults<Job>
    
    @State private var selectedJob: Job?
    @State private var showingJobSelection = false
    @State private var shiftNotes = ""
    @State private var selectedShiftType = "Regular"
    @State private var showingAddShift = false
    @State private var showingTemplates = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Time Display
                    TimeDisplayView()
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.0), value: UUID())
                    
                    // Job Selection
                    JobSelectionView()
                        .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: UUID())
                    
                    // Shift Type Display
                    ShiftTypeDisplayView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: UUID())
                    
                    // Notes Section
                    NotesSectionView()
                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: UUID())
                    
                    // Control Buttons
                    ControlButtonsView()
                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: UUID())
                    
                    // Bottom padding to prevent interference with tab bar
                    Color.clear
                        .frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(
                ZStack {
                    // Base gradient
                    LinearGradient(
                        colors: [
                            TISColors.background,
                            TISColors.background.opacity(0.95),
                            TISColors.primary.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Animated gradient overlay
                    LinearGradient(
                        colors: [
                            TISColors.primary.opacity(0.05),
                            Color.clear,
                            TISColors.accent.opacity(0.03)
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                    .opacity(0.8)
                }
            )
            .navigationTitle("Time Tracking")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showingTemplates = true
                        }) {
                            Image(systemName: "clock.badge.checkmark")
                                .font(.title2)
                                .foregroundColor(TISColors.primary)
                        }
                        
                        Button(action: {
                            showingAddShift = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(TISColors.primary)
                        }
                    }
                }
            }
        }
        .onAppear {
            timeTracker.setContext(viewContext)
        }
        .sheet(isPresented: $showingAddShift) {
            AddManualShiftView(jobs: jobs)
        }
        .sheet(isPresented: $showingTemplates) {
            ShiftTemplatesView()
        }
    }
    
    @ViewBuilder
    private func TimeDisplayView() -> some View {
        VStack(spacing: 24) {
            // Main Timer Circle with Enhanced Design
            ZStack {
                // Glow rings
                GlowRingsView(isTracking: timeTracker.isTracking)
                
                // Main circle
                MainCircleView(isTracking: timeTracker.isTracking)
                
                // Inner content
                InnerContentView(isTracking: timeTracker.isTracking, elapsedTime: timeTracker.elapsedTime, formatTime: formatTime)
            }
            .shadow(color: timeTracker.isTracking ? TISColors.success.opacity(0.4) : TISColors.primary.opacity(0.4), radius: 25, x: 0, y: 15)
            
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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Notes")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !shiftNotes.isEmpty {
                    Text("\(shiftNotes.count) characters")
                        .font(.caption)
                        .foregroundColor(TISColors.secondaryText)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("Add notes about this shift...", text: $shiftNotes, axis: .vertical)
                    .textFieldStyle(TISTextFieldStyle())
                    .lineLimit(3...6)
                    .onChange(of: shiftNotes) { oldValue, newValue in
                        // Add haptic feedback when typing
                        if newValue.count > oldValue.count {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    }
                
                if !shiftNotes.isEmpty {
                    HStack {
                        Image(systemName: "text.badge.plus")
                            .font(.caption)
                            .foregroundColor(TISColors.primary)
                        
                        Text("Notes will be saved with your shift")
                            .font(.caption)
                            .foregroundColor(TISColors.secondaryText)
                        
                        Spacer()
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: shiftNotes.isEmpty)
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
                            Text(localizationManager.localizedString(for: "time_tracking.end_shift"))
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
                .accessibilityLabel("End shift button")
                .accessibilityHint("Stop tracking current shift and save to history")
                .buttonStyle(TISPressableButtonStyle())
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
                            Text(localizationManager.localizedString(for: "time_tracking.start_shift"))
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
                            .fill(selectedJob == nil ? LinearGradient(colors: [TISColors.secondaryText, TISColors.secondaryText], startPoint: .topLeading, endPoint: .bottomTrailing) : TISColors.successGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .tisShadow(TISShadows.medium)
                }
                .disabled(selectedJob == nil || timeTracker.isTracking)
                .opacity((selectedJob == nil || timeTracker.isTracking) ? 0.6 : 1.0)
                .scaleEffect((selectedJob == nil || timeTracker.isTracking) ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: selectedJob == nil)
                .accessibilityLabel("Start shift button")
                .accessibilityHint(selectedJob == nil ? "Select a job first" : "Begin tracking time for selected job")
                .buttonStyle(TISPressableButtonStyle())
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
        guard let job = selectedJob else {
            hapticNotifyWarning()
            return
        }
        
        // Check if already tracking
        if timeTracker.isTracking {
            hapticNotifyWarning()
            return
        }
        
        hapticTapMedium()
        timeTracker.startTracking(for: job)
        
        // Set notes (shift type will be set automatically when ending)
        if let currentShift = timeTracker.currentShift {
            currentShift.notes = shiftNotes
        }
        
        do {
            try viewContext.save()
            hapticNotifySuccess()
        } catch {
            print("Error saving shift start: \(error)")
            hapticNotifyError()
        }
    }
    
    private func endShift() {
        // Check if actually tracking
        guard timeTracker.isTracking else {
            print("Not currently tracking a shift")
            hapticNotifyWarning()
            return
        }
        
        hapticTapMedium()
        if let currentShift = timeTracker.currentShift {
            currentShift.notes = shiftNotes
        }
        
        do {
            try viewContext.save()
            hapticNotifySuccess()
        } catch {
            print("Error saving shift end: \(error)")
            hapticNotifyError()
        }
        
        timeTracker.endTracking()
        shiftNotes = ""
        selectedJob = nil
    }
    
    // MARK: - Local Haptic Helpers
    private func hapticTapMedium() {
    #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    #endif
    }
    
    private func hapticNotifySuccess() {
    #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    #endif
    }
    
    private func hapticNotifyWarning() {
    #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    #endif
    }
    
    private func hapticNotifyError() {
    #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    #endif
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

struct GlowRingsView: View {
    let isTracking: Bool
    
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                GlowRingView(index: index, isTracking: isTracking)
            }
        }
    }
}

struct GlowRingView: View {
    let index: Int
    let isTracking: Bool
    
    private var ringSize: CGFloat {
        220 + CGFloat(index * 20)
    }
    
    private var blurRadius: CGFloat {
        8 + CGFloat(index * 4)
    }
    
    private var opacity: Double {
        0.1 - Double(index) * 0.03
    }
    
    private var scaleEffect: CGFloat {
        isTracking ? 1.0 + CGFloat(index) * 0.1 : 1.0
    }
    
    private var animationDuration: Double {
        2.0 + Double(index) * 0.5
    }
    
    var body: some View {
        Circle()
            .fill(isTracking ? TISColors.successGradient : TISColors.primaryGradient)
            .frame(width: ringSize, height: ringSize)
            .blur(radius: blurRadius)
            .opacity(opacity)
            .scaleEffect(scaleEffect)
            .animation(.easeInOut(duration: animationDuration).repeatForever(autoreverses: true), value: isTracking)
    }
}

struct MainCircleView: View {
    let isTracking: Bool
    
    var body: some View {
        Circle()
            .fill(isTracking ? TISColors.successGradient : TISColors.cardGradient)
            .frame(width: 200, height: 200)
            .scaleEffect(isTracking ? 1.05 : 1.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isTracking)
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
    }
}

struct InnerContentView: View {
    let isTracking: Bool
    let elapsedTime: TimeInterval
    let formatTime: (TimeInterval) -> String
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Status icon with pulsing effect
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .scaleEffect(isTracking ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isTracking)
                
                Image(systemName: isTracking ? "play.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .scaleEffect(isTracking ? 1.1 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isTracking)
            }
            
            // Time display with enhanced typography
            VStack(spacing: 4) {
                if isTracking {
                    Text(formatTime(elapsedTime))
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .animation(.easeInOut(duration: 0.3), value: elapsedTime)
                        .contentTransition(.numericText())
                } else {
                    Text("00:00:00")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Status text with enhanced styling
                Text(isTracking ? localizationManager.localizedString(for: "time_tracking.tracking") : localizationManager.localizedString(for: "time_tracking.ready"))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(3)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.2))
                    )
            }
        }
    }
}

struct TISPressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    var pressedOpacity: Double = 0.85

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? pressedOpacity : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

#Preview {
    TimeTrackingView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(TimeTracker())
        .environmentObject(LocalizationManager.shared)
}
