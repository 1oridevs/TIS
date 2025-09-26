import SwiftUI
import CoreData
import Charts

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
    @State private var showingAnalytics = false
    @State private var selectedJob: Job?
    @State private var shiftToEdit: Shift?
    
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
    
    var analyticsInsights: [AnalyticsInsight] {
        let shifts = filteredShifts
        var insights: [AnalyticsInsight] = []
        
        if !shifts.isEmpty {
            let totalEarnings = shifts.reduce(0.0) { total, shift in
                total + calculateTotalEarnings(for: shift)
            }
            let totalHours = shifts.reduce(0.0) { total, shift in
                total + calculateDurationInHours(for: shift)
            }
            let averageHourlyRate = totalHours > 0 ? totalEarnings / totalHours : 0
            
            // Best earning day
            let bestDay = shifts.max { shift1, shift2 in
                calculateTotalEarnings(for: shift1) < calculateTotalEarnings(for: shift2)
            }
            if let bestDay = bestDay, let startTime = bestDay.startTime {
                insights.append(AnalyticsInsight(
                    title: "Best Earning Day",
                    value: localizationManager.formatCurrency(calculateTotalEarnings(for: bestDay)),
                    subtitle: startTime.formatted(.dateTime.weekday().month().day()),
                    icon: "star.fill",
                    color: .green
                ))
            }
            
            // Average daily earnings
            let days = Set(shifts.compactMap { $0.startTime?.formatted(.dateTime.year().month().day()) }).count
            if days > 0 {
                insights.append(AnalyticsInsight(
                    title: "Average Daily Earnings",
                    value: localizationManager.formatCurrency(totalEarnings / Double(days)),
                    subtitle: "Based on \(days) days",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                ))
            }
            
            // Total hours worked
            insights.append(AnalyticsInsight(
                title: "Total Hours",
                value: String(format: "%.1f", totalHours),
                subtitle: "Hours worked",
                icon: "clock.fill",
                color: .orange
            ))
            
            // Average hourly rate
            insights.append(AnalyticsInsight(
                title: "Average Rate",
                value: localizationManager.formatCurrency(averageHourlyRate),
                subtitle: "Per hour",
                icon: "dollarsign.circle.fill",
                color: .purple
            ))
        }
        
        return insights
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
                    HStack {
                        Button(action: { showingAnalytics = true }) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                        }
                        
                        Button(action: { showingExportOptions = true }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView(shifts: filteredShifts)
        }
        .sheet(isPresented: $showingAnalytics) {
            AnalyticsInsightsView(insights: analyticsInsights)
        }
        .sheet(item: $shiftToEdit) { shift in
            SimpleEditShiftView(shift: shift)
        }
    }
    
    @ViewBuilder
    private func SummaryCardsView() -> some View {
        HStack(spacing: 16) {
            SummaryCard(
                title: "Total Earnings",
                value: localizationManager.formatCurrency(totalEarnings),
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
                    Text(localizationManager.localizedString(for: "history.no_history"))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text(localizationManager.localizedString(for: "history.no_history_subtitle"))
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
                    ShiftDetailRowView(shift: shift, onEdit: {
                        shiftToEdit = shift
                    })
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
    let onEdit: (() -> Void)?
    @EnvironmentObject private var localizationManager: LocalizationManager
    
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
                    Text("\(localizationManager.localizedString(for: "history.start_time")): \(startTime, style: .time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let endTime = shift.endTime {
                    Text("\(localizationManager.localizedString(for: "history.end_time")): \(endTime, style: .time)")
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
                    Text(localizationManager.localizedString(for: "history.bonuses"))
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
            
            // Edit button
            if let onEdit = onEdit {
                HStack {
                    Spacer()
                    Button(action: onEdit) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.caption)
                            Text(localizationManager.localizedString(for: "history.edit"))
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.top, 8)
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
    @EnvironmentObject private var localizationManager: LocalizationManager
    @StateObject private var exportManager = ExportManager.shared
    @State private var showingShareSheet = false
    @State private var fileToShare: URL?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(localizationManager.localizedString(for: "history.export_options"))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(localizationManager.localizedString(for: "history.export_subtitle"))
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

// MARK: - AnalyticsInsight

struct AnalyticsInsight: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
}

// MARK: - AnalyticsInsightsView

struct AnalyticsInsightsView: View {
    let insights: [AnalyticsInsight]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if insights.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text(localizationManager.localizedString(for: "history.no_analytics"))
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Analytics will appear here once you have some shift data.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 50)
                    } else {
                        VStack(spacing: 20) {
                            // Enhanced Analytics Cards
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(insights) { insight in
                                    InsightCard(insight: insight)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Enhanced Charts Section
                            VStack(spacing: 16) {
                                Text("Detailed Analytics")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                // Earnings Trend Chart
                                EarningsTrendChart(insights: insights)
                                
                                // Hours Worked Chart
                                HoursWorkedChart(insights: insights)
                                
                                // Job Performance Chart
                                JobPerformanceChart(insights: insights)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Analytics Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InsightCard: View {
    let insight: AnalyticsInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: insight.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(insight.color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(insight.value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(insight.subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(insight.color.opacity(0.1))
        )
    }
}

// MARK: - SimpleEditShiftView

struct SimpleEditShiftView: View {
    let shift: Shift
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var notes: String
    @State private var bonusAmount: Double
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var isSaving = false
    
    init(shift: Shift) {
        self.shift = shift
        self._notes = State(initialValue: shift.notes ?? "")
        self._bonusAmount = State(initialValue: shift.bonusAmount)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(localizationManager.localizedString(for: "shifts.edit_shift"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(localizationManager.localizedString(for: "shifts.edit_shift_subtitle"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Edit Form
                VStack(spacing: 16) {
                    // Notes Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundColor(TISColors.primaryText)
                        
                        TextField(localizationManager.localizedString(for: "shifts.notes_placeholder"), text: $notes, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    // Bonus Amount Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bonus Amount")
                            .font(.headline)
                            .foregroundColor(TISColors.primaryText)
                        
                        HStack {
                            Text(localizationManager.currentCurrency.symbol)
                                .font(.title2)
                                .foregroundColor(TISColors.primary)
                            
                            TextField("0.00", value: $bonusAmount, format: .currency(code: localizationManager.currentCurrency.rawValue))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                    }
                    
                    // Shift Info (Read-only)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Shift Information")
                            .font(.headline)
                            .foregroundColor(TISColors.primaryText)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Job:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(shift.job?.name ?? "Unknown")
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Start:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(shift.startTime ?? Date(), style: .date)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("End:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(shift.endTime ?? Date(), style: .date)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Type:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(shift.shiftType ?? "Regular")
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Save Button
                Button(action: saveChanges) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "checkmark")
                        }
                        Text(isSaving ? localizationManager.localizedString(for: "common.saving") : localizationManager.localizedString(for: "common.save"))
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [TISColors.primary, TISColors.primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: TISColors.primary.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .disabled(isSaving)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
        .toast(isShowing: $showingToast, message: toastMessage, type: .success)
    }
    
    private func saveChanges() {
        isSaving = true
        
        // Update shift properties
        shift.notes = notes.isEmpty ? nil : notes
        shift.bonusAmount = bonusAmount
        
        do {
            try viewContext.save()
            toastMessage = localizationManager.localizedString(for: "shifts.shift_updated_success")
            showingToast = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            toastMessage = "Failed to save changes: \(error.localizedDescription)"
            showingToast = true
        }
        
        isSaving = false
    }
}

// MARK: - Enhanced Analytics Charts

struct EarningsTrendChart: View {
    let insights: [AnalyticsInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Earnings Trend")
                .font(.headline)
                .foregroundColor(TISColors.primaryText)
            
            Chart {
                ForEach(insights.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Period", index),
                        y: .value("Earnings", Double(insights[index].value.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "")) ?? 0)
                    )
                    .foregroundStyle(TISColors.primary)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Period", index),
                        y: .value("Earnings", Double(insights[index].value.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "")) ?? 0)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [TISColors.primary.opacity(0.3), TISColors.primary.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .frame(height: 200)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .padding(.horizontal)
    }
}

struct HoursWorkedChart: View {
    let insights: [AnalyticsInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hours Worked")
                .font(.headline)
                .foregroundColor(TISColors.primaryText)
            
            Chart {
                ForEach(insights.indices, id: \.self) { index in
                    BarMark(
                        x: .value("Period", index),
                        y: .value("Hours", Double(insights[index].value.replacingOccurrences(of: "h", with: "")) ?? 0)
                    )
                    .foregroundStyle(TISColors.accent)
                    .cornerRadius(4)
                }
            }
            .frame(height: 200)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .padding(.horizontal)
    }
}

struct JobPerformanceChart: View {
    let insights: [AnalyticsInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Job Performance")
                .font(.headline)
                .foregroundColor(TISColors.primaryText)
            
            Chart {
                ForEach(insights.indices, id: \.self) { index in
                    SectorMark(
                        angle: .value("Value", Double(insights[index].value.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "")) ?? 0),
                        innerRadius: .ratio(0.3),
                        angularInset: 2
                    )
                    .foregroundStyle(TISColors.primary)
                    .opacity(0.8)
                }
            }
            .frame(height: 200)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .padding(.horizontal)
    }
}
