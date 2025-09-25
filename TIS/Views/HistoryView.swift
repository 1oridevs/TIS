import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var localizationManager: LocalizationManager
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Shift.startTime, ascending: false)],
        predicate: NSPredicate(format: "isActive == NO"),
        animation: .default)
    private var shifts: FetchedResults<Shift>
    
    @State private var selectedPeriod = "All"
    @State private var showingExportOptions = false
    
    let periods = ["All", "Today", "This Week", "This Month", "Last 30 Days"]
    
    var filteredShifts: [Shift] {
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedPeriod {
        case "Today":
            return shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return calendar.isDate(startTime, inSameDayAs: now)
            }
        case "This Week":
            return shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return calendar.isDate(startTime, equalTo: now, toGranularity: .weekOfYear)
            }
        case "This Month":
            return shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return calendar.isDate(startTime, equalTo: now, toGranularity: .month)
            }
        case "Last 30 Days":
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            return shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return startTime >= thirtyDaysAgo
            }
        default:
            return Array(shifts)
        }
    }
    
    var totalEarnings: Double {
        filteredShifts.reduce(0.0) { total, shift in
            total + calculateTotalEarnings(for: shift)
        }
    }
    
    var totalHours: Double {
        filteredShifts.reduce(0.0) { total, shift in
            total + calculateDurationInHours(for: shift)
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime else { return 0 }
        let endTime = shift.endTime ?? Date()
        return endTime.timeIntervalSince(startTime) / 3600
    }
    
    private func calculateTotalEarnings(for shift: Shift) -> Double {
        let duration = calculateDurationInHours(for: shift)
        let baseEarnings = duration * (shift.job?.hourlyRate ?? 0.0)
        let bonusAmount = shift.bonusAmount  
        return baseEarnings + bonusAmount
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background
                LinearGradient(
                    colors: [
                        TISColors.background,
                        TISColors.background.opacity(0.95),
                        TISColors.primary.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Summary Cards
                    SummaryCardsView()
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.0), value: UUID())
                    
                    // Period Selector
                    PeriodSelectorView()
                        .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: UUID())
                    
                    // Shifts List
                    ShiftsListView()
                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: UUID())
                        .refreshable {
                            let current = selectedPeriod
                            selectedPeriod = "All"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                selectedPeriod = current
                            }
                        }
                }
            }
            .navigationTitle(localizationManager.localizedString(for: "history.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingExportOptions = true }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView(shifts: filteredShifts)
        }
    }
    
    @ViewBuilder
    private func SummaryCardsView() -> some View {
        HStack(spacing: 16) {
            SummaryCard(
                title: "Total Earnings",
                value: String(format: "$%.2f", totalEarnings),
                icon: "dollarsign.circle.fill",
                color: .green
            )
            
            SummaryCard(
                title: "Total Hours",
                value: String(format: "%.1fh", totalHours),
                icon: "clock.fill",
                color: .blue
            )
            
            SummaryCard(
                title: "Shifts",
                value: "\(filteredShifts.count)",
                icon: "briefcase.fill",
                color: .orange
            )
        }
        .padding()
    }
    
    @ViewBuilder
    private func PeriodSelectorView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(periods, id: \.self) { period in
                    Button(action: { selectedPeriod = period }) {
                        Text(period)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedPeriod == period ? Color.blue : Color(.systemGray6))
                            .foregroundColor(selectedPeriod == period ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func ShiftsListView() -> some View {
        if filteredShifts.isEmpty {
            // Beautiful empty state
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(TISColors.warning.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: UUID())
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 50, weight: .light))
                        .foregroundColor(TISColors.warning)
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: UUID())
                }
                
                VStack(spacing: 12) {
                    Text("No History Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text("Your shift history will appear here once you start tracking time.")
                        .font(.body)
                        .foregroundColor(TISColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 40)
        } else {
            List {
                ForEach(filteredShifts, id: \.id) { shift in
                    ShiftDetailRowView(shift: shift)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ShiftDetailRowView: View {
    let shift: Shift
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(shift.job?.name ?? "Unknown Job")
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Image(systemName: shiftTypeIcon(for: shift.shiftType ?? "Regular"))
                            .font(.caption)
                            .foregroundColor(shiftTypeColor(for: shift.shiftType ?? "Regular"))
                        
                        Text(shift.shiftType ?? "Regular")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "$%.2f", calculateTotalEarnings(for: shift)))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text(String(format: "%.1fh", calculateDurationInHours(for: shift)))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Time details
            HStack {
                if let startTime = shift.startTime {
                    Text("Start: \(startTime, style: .time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let endTime = shift.endTime {
                    Text("End: \(endTime, style: .time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(shift.startTime ?? Date(), style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Notes
            if let notes = shift.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            
            // Bonuses
            if let bonuses = shift.bonuses?.allObjects as? [Bonus], !bonuses.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bonuses:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ForEach(bonuses, id: \.id) { bonus in
                        HStack {
                            Text(bonus.name ?? "Unknown Bonus")
                                .font(.caption)
                            Spacer()
                            Text(String(format: "$%.2f", bonus.amount))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func shiftTypeIcon(for shiftType: String) -> String {
        switch shiftType {
        case "Overtime":
            return "clock.badge.exclamationmark"
        case "Special Event":
            return "star.fill"
        default:
            return "clock"
        }
    }
    
    private func shiftTypeColor(for shiftType: String) -> Color {
        switch shiftType {
        case "Overtime":
            return .orange
        case "Special Event":
            return .purple
        default:
            return .blue
        }
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime else { return 0 }
        let endTime = shift.endTime ?? Date()
        return endTime.timeIntervalSince(startTime) / 3600
    }
    
    private func calculateTotalEarnings(for shift: Shift) -> Double {
        let duration = calculateDurationInHours(for: shift)
        let baseEarnings = duration * (shift.job?.hourlyRate ?? 0.0)
        let bonusAmount = shift.bonusAmount  
        return baseEarnings + bonusAmount
    }
}

struct ExportOptionsView: View {
    let shifts: [Shift]
    @Environment(\.dismiss) private var dismiss
    @StateObject private var exportManager = ExportManager.shared
    @State private var showingShareSheet = false
    @State private var fileToShare: URL?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export Options")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose how you want to export your shift data")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    ExportOptionButton(
                        title: "Export as CSV",
                        description: "Spreadsheet format for Excel, Numbers, etc.",
                        icon: "tablecells.fill",
                        color: .green
                    ) {
                        exportAsCSV()
                    }
                    
                    ExportOptionButton(
                        title: "Export as PDF",
                        description: "Formatted report for printing or sharing",
                        icon: "doc.fill",
                        color: .blue
                    ) {
                        exportAsPDF()
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let fileURL = fileToShare {
                ShareSheet(items: [fileURL])
            }
        }
        .alert("Export", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func exportAsCSV() {
        guard let fileURL = exportManager.exportShiftsAsCSV(shifts) else {
            alertMessage = "Failed to export CSV file"
            showingAlert = true
            return
        }
        
        fileToShare = fileURL
        showingShareSheet = true
    }
    
    private func exportAsPDF() {
        guard let fileURL = exportManager.exportShiftsAsPDF(shifts) else {
            alertMessage = "Failed to export PDF file"
            showingAlert = true
            return
        }
        
        fileToShare = fileURL
        showingShareSheet = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ExportOptionButton: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

#Preview {
    HistoryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
