import SwiftUI
import CoreData
import Charts

struct AnalyticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var localizationManager: LocalizationManager
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Shift.startTime, ascending: false)],
        predicate: NSPredicate(format: "isActive == NO"),
        animation: .default)
    private var shifts: FetchedResults<Shift>
    
    @State private var selectedPeriod = "This Month"
    @State private var selectedJob: Job?
    @State private var showingInsights = false
    @State private var isAnimating = false
    @State private var showingExportOptions = false
    @State private var showingDetailedReport = false
    @State private var selectedChartType = "Earnings"
    @State private var showingFilters = false
    
    let periods = ["This Week", "This Month", "Last 3 Months", "This Year", "All Time"]
    let chartTypes = ["Earnings", "Hours", "Shifts", "Productivity"]
    
    var filteredShifts: [Shift] {
        let now = Date()
        let calendar = Calendar.current
        
        let shiftsArray = Array(shifts)
        let jobFiltered = selectedJob == nil ? shiftsArray : shiftsArray.filter { $0.job == selectedJob }
        
        switch selectedPeriod {
        case "This Week":
            return jobFiltered.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return calendar.isDate(startTime, equalTo: now, toGranularity: .weekOfYear)
            }
        case "This Month":
            return jobFiltered.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return calendar.isDate(startTime, equalTo: now, toGranularity: .month)
            }
        case "Last 3 Months":
            let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            return jobFiltered.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return startTime >= threeMonthsAgo
            }
        case "This Year":
            return jobFiltered.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return calendar.isDate(startTime, equalTo: now, toGranularity: .year)
            }
        default:
            return jobFiltered
        }
    }
    
    var totalEarnings: Double {
        calculateTotalEarnings(for: filteredShifts)
    }
    
    var totalHours: Double {
        calculateTotalHours(for: filteredShifts)
    }
    
    var averageHourlyRate: Double {
        totalHours > 0 ? totalEarnings / totalHours : 0
    }
    
    var earningsByType: (regular: Double, overtime: Double, special: Double, bonus: Double) {
        calculateEarningsBreakdown(for: filteredShifts)
    }
    
    var analyticsInsights: [AnalyticsInsight] {
        let shifts = filteredShifts
        var insights: [AnalyticsInsight] = []
        
        if !shifts.isEmpty {
            let totalEarnings = calculateTotalEarnings(for: shifts)
            let totalHours = calculateTotalHours(for: shifts)
            let averageHourlyRate = totalHours > 0 ? totalEarnings / totalHours : 0
            
            // Best earning day
            let bestDay = shifts.max { calculateTotalEarnings(for: [$0]) < calculateTotalEarnings(for: [$1]) }
            if let bestDay = bestDay, let startTime = bestDay.startTime {
                insights.append(AnalyticsInsight(
                    title: "Best Earning Day",
                    value: localizationManager.formatCurrency(calculateTotalEarnings(for: [bestDay])),
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header with Period Selector
                    AnalyticsHeaderView(
                        selectedPeriod: $selectedPeriod,
                        periods: periods,
                        totalEarnings: totalEarnings,
                        totalHours: totalHours,
                        isAnimating: isAnimating
                    )
                    
                    // Key Metrics Cards
                    KeyMetricsSection(
                        totalEarnings: totalEarnings,
                        totalHours: totalHours,
                        averageHourlyRate: averageHourlyRate,
                        earningsByType: earningsByType
                    )
                    
                    // Chart Type Selector
                    ChartTypeSelector(selectedType: $selectedChartType, chartTypes: chartTypes)
                    
                    // Earnings Chart
                    EarningsChartView(shifts: filteredShifts, period: selectedPeriod)
                    
                    // Analytics Insights
                    if !analyticsInsights.isEmpty {
                        AnalyticsInsightsSection(insights: analyticsInsights)
                    }
                    
                    // Hours Chart
                    HoursChartView(shifts: filteredShifts, period: selectedPeriod)
                    
                    // Top Jobs Section
                    TopJobsSection(shifts: filteredShifts)
                    
                    // Insights Section
                    InsightsSection(
                        shifts: filteredShifts,
                        showingInsights: $showingInsights
                    )
                    
                    // Job Filter
                    JobFilterSection(selectedJob: $selectedJob)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(
                ZStack {
                    // Enhanced gradient background
                    LinearGradient(
                        colors: [
                            TISColors.background,
                            TISColors.background.opacity(0.95),
                            TISColors.primary.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Subtle pattern overlay
                    GeometryReader { geometry in
                        Circle()
                            .fill(TISColors.accent.opacity(0.02))
                            .frame(width: 300, height: 300)
                            .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.3)
                            .blur(radius: 30)
                        
                        Circle()
                            .fill(TISColors.primary.opacity(0.02))
                            .frame(width: 200, height: 200)
                            .position(x: geometry.size.width * 0.3, y: geometry.size.height * 0.7)
                            .blur(radius: 25)
                    }
                }
            )
            .navigationTitle(localizationManager.localizedString(for: "analytics.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showingFilters = true }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(TISColors.primary)
                        }
                        
                        Button(action: { showingExportOptions = true }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(TISColors.primary)
                        }
                        
                        Button(action: { showingInsights.toggle() }) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(TISColors.primary)
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                isAnimating = true
            }
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView(shifts: Array(filteredShifts))
        }
        .sheet(isPresented: $showingFilters) {
            AnalyticsFiltersView(
                selectedPeriod: $selectedPeriod,
                selectedJob: $selectedJob,
                periods: periods
            )
        }
        .sheet(isPresented: $showingDetailedReport) {
            DetailedReportView(shifts: Array(filteredShifts))
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateTotalEarnings(for shifts: [Shift]) -> Double {
        shifts.reduce(0) { total, shift in
            let baseEarnings = calculateBaseEarnings(for: shift)
            let bonusEarnings = shift.bonusAmount
            return total + baseEarnings + bonusEarnings
        }
    }
    
    private func calculateTotalHours(for shifts: [Shift]) -> Double {
        shifts.reduce(0) { total, shift in
            total + calculateDurationInHours(for: shift)
        }
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime,
              let endTime = shift.endTime else { return 0 }
        return endTime.timeIntervalSince(startTime) / 3600
    }
    
    private func calculateBaseEarnings(for shift: Shift) -> Double {
        guard let job = shift.job else { return 0 }
        let hours = calculateDurationInHours(for: shift)
        let hourlyRate = job.hourlyRate
        
        switch shift.shiftType {
        case "Overtime":
            return hours * hourlyRate * 1.5
        case "Special Event":
            return hours * hourlyRate * 1.25
        default:
            return hours * hourlyRate
        }
    }
    
    private func calculateEarningsBreakdown(for shifts: [Shift]) -> (regular: Double, overtime: Double, special: Double, bonus: Double) {
        var regular: Double = 0
        var overtime: Double = 0
        var special: Double = 0
        var bonus: Double = 0
        
        for shift in shifts {
            let baseEarnings = calculateBaseEarnings(for: shift)
            let bonusEarnings = shift.bonusAmount
            
            switch shift.shiftType {
            case "Overtime":
                overtime += baseEarnings
            case "Special Event":
                special += baseEarnings
            default:
                regular += baseEarnings
            }
            
            bonus += bonusEarnings
        }
        
        return (regular, overtime, special, bonus)
    }
}

// MARK: - Analytics Header View

struct AnalyticsHeaderView: View {
    @Binding var selectedPeriod: String
    let periods: [String]
    let totalEarnings: Double
    let totalHours: Double
    let isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Period Selector
            Picker("Period", selection: $selectedPeriod) {
                ForEach(periods, id: \.self) { period in
                    Text(period).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(TISColors.cardBackground)
            .cornerRadius(12)
            
            // Summary Stats
            HStack(spacing: 20) {
                StatCard(
                    title: "Total Earnings",
                    value: String(format: "%.2f", totalEarnings),
                    icon: "dollarsign.circle.fill",
                    color: TISColors.success,
                    isAnimating: isAnimating
                )
                
                StatCard(
                    title: "Total Hours",
                    value: String(format: "%.1f", totalHours),
                    icon: "clock.fill",
                    color: TISColors.primary,
                    isAnimating: isAnimating
                )
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(TISColors.primaryText)
            
            Text(title)
                .font(.caption)
                .foregroundColor(TISColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(TISColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Key Metrics Section

struct KeyMetricsSection: View {
    let totalEarnings: Double
    let totalHours: Double
    let averageHourlyRate: Double
    let earningsByType: (regular: Double, overtime: Double, special: Double, bonus: Double)
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundColor(TISColors.primary)
                    
                    Text("Key Metrics")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    MetricRow(
                        title: "Average Hourly Rate",
                        value: String(format: "$%.2f", averageHourlyRate),
                        color: TISColors.primary
                    )
                    
                    Divider()
                    
                    MetricRow(
                        title: "Regular Earnings",
                        value: String(format: "$%.2f", earningsByType.regular),
                        color: TISColors.success
                    )
                    
                    MetricRow(
                        title: "Overtime Earnings",
                        value: String(format: "$%.2f", earningsByType.overtime),
                        color: TISColors.warning
                    )
                    
                    MetricRow(
                        title: "Special Event Earnings",
                        value: String(format: "$%.2f", earningsByType.special),
                        color: TISColors.purple
                    )
                    
                    MetricRow(
                        title: "Bonus Earnings",
                        value: String(format: "$%.2f", earningsByType.bonus),
                        color: TISColors.gold
                    )
                }
            }
        }
    }
}

struct MetricRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(TISColors.primaryText)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Earnings Chart View

struct EarningsChartView: View {
    let shifts: [Shift]
    let period: String
    
    var chartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        
        var data: [ChartDataPoint] = []
        
        switch period {
        case "This Week":
            for i in 0..<7 {
                let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
                let dayShifts = shifts.filter { shift in
                    guard let startTime = shift.startTime else { return false }
                    return calendar.isDate(startTime, inSameDayAs: date)
                }
                let earnings = calculateTotalEarnings(for: dayShifts)
                data.append(ChartDataPoint(date: date, value: earnings, label: calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]))
            }
        case "This Month":
            for i in 0..<30 {
                let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
                let dayShifts = shifts.filter { shift in
                    guard let startTime = shift.startTime else { return false }
                    return calendar.isDate(startTime, inSameDayAs: date)
                }
                let earnings = calculateTotalEarnings(for: dayShifts)
                data.append(ChartDataPoint(date: date, value: earnings, label: "\(calendar.component(.day, from: date))"))
            }
        default:
            // For longer periods, group by week
            for i in 0..<12 {
                let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: now) ?? now
                let weekShifts = shifts.filter { shift in
                    guard let startTime = shift.startTime else { return false }
                    return calendar.isDate(startTime, equalTo: weekStart, toGranularity: .weekOfYear)
                }
                let earnings = calculateTotalEarnings(for: weekShifts)
                data.append(ChartDataPoint(date: weekStart, value: earnings, label: "Week \(12-i)"))
            }
        }
        
        return data.reversed()
    }
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundColor(TISColors.success)
                    
                    Text("Earnings Trend")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                if chartData.isEmpty {
                    // Beautiful empty state for chart
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(TISColors.primary.opacity(0.1))
                                .frame(width: 80, height: 80)
                                .scaleEffect(1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: UUID())
                            
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 30, weight: .light))
                                .foregroundColor(TISColors.primary)
                                .scaleEffect(1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: UUID())
                        }
                        
                        Text("No Data to Analyze")
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 200)
                } else {
                    Chart(chartData) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Earnings", dataPoint.value)
                        )
                        .foregroundStyle(TISColors.successGradient)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
                        AreaMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Earnings", dataPoint.value)
                        )
                        .foregroundStyle(TISColors.successGradient.opacity(0.3))
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: period == "This Week" ? 1 : 7)) { value in
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(period == "This Week" ? 
                                         Calendar.current.shortWeekdaySymbols[Calendar.current.component(.weekday, from: date) - 1] :
                                         "\(Calendar.current.component(.day, from: date))")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let amount = value.as(Double.self) {
                                    Text("$\(Int(amount))")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func calculateTotalEarnings(for shifts: [Shift]) -> Double {
        shifts.reduce(0) { total, shift in
            let baseEarnings = calculateBaseEarnings(for: shift)
            let bonusEarnings = shift.bonusAmount
            return total + baseEarnings + bonusEarnings
        }
    }
    
    private func calculateBaseEarnings(for shift: Shift) -> Double {
        guard let job = shift.job else { return 0 }
        let hours = calculateDurationInHours(for: shift)
        let hourlyRate = job.hourlyRate
        
        switch shift.shiftType {
        case "Overtime":
            return hours * hourlyRate * 1.5
        case "Special Event":
            return hours * hourlyRate * 1.25
        default:
            return hours * hourlyRate
        }
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime,
              let endTime = shift.endTime else { return 0 }
        return endTime.timeIntervalSince(startTime) / 3600
    }
}

// MARK: - Hours Chart View

struct HoursChartView: View {
    let shifts: [Shift]
    let period: String
    
    var chartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        
        var data: [ChartDataPoint] = []
        
        switch period {
        case "This Week":
            for i in 0..<7 {
                let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
                let dayShifts = shifts.filter { shift in
                    guard let startTime = shift.startTime else { return false }
                    return calendar.isDate(startTime, inSameDayAs: date)
                }
                let hours = calculateTotalHours(for: dayShifts)
                data.append(ChartDataPoint(date: date, value: hours, label: calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]))
            }
        case "This Month":
            for i in 0..<30 {
                let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
                let dayShifts = shifts.filter { shift in
                    guard let startTime = shift.startTime else { return false }
                    return calendar.isDate(startTime, inSameDayAs: date)
                }
                let hours = calculateTotalHours(for: dayShifts)
                data.append(ChartDataPoint(date: date, value: hours, label: "\(calendar.component(.day, from: date))"))
            }
        default:
            // For longer periods, group by week
            for i in 0..<12 {
                let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: now) ?? now
                let weekShifts = shifts.filter { shift in
                    guard let startTime = shift.startTime else { return false }
                    return calendar.isDate(startTime, equalTo: weekStart, toGranularity: .weekOfYear)
                }
                let hours = calculateTotalHours(for: weekShifts)
                data.append(ChartDataPoint(date: weekStart, value: hours, label: "Week \(12-i)"))
            }
        }
        
        return data.reversed()
    }
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.title2)
                        .foregroundColor(TISColors.primary)
                    
                    Text("Hours Worked")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                if chartData.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.badge.xmark")
                            .font(.system(size: 40))
                            .foregroundColor(TISColors.secondaryText)
                            .shimmer()
                        
                        Text("No data available")
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                            .shimmer()
                    }
                    .frame(height: 200)
                } else {
                    Chart(chartData) { dataPoint in
                        BarMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Hours", dataPoint.value)
                        )
                        .foregroundStyle(TISColors.primaryGradient)
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: period == "This Week" ? 1 : 7)) { value in
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(period == "This Week" ? 
                                         Calendar.current.shortWeekdaySymbols[Calendar.current.component(.weekday, from: date) - 1] :
                                         "\(Calendar.current.component(.day, from: date))")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let hours = value.as(Double.self) {
                                    Text("\(Int(hours))h")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func calculateTotalHours(for shifts: [Shift]) -> Double {
        shifts.reduce(0) { total, shift in
            total + calculateDurationInHours(for: shift)
        }
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime,
              let endTime = shift.endTime else { return 0 }
        return endTime.timeIntervalSince(startTime) / 3600
    }
}

// MARK: - Top Jobs Section

struct TopJobsSection: View {
    let shifts: [Shift]
    
    var topJobs: [(Job?, Double)] {
        let jobEarnings = Dictionary(grouping: shifts) { $0.job }
            .mapValues { shifts in
                calculateTotalEarnings(for: shifts)
            }
            .sorted { $0.value > $1.value }
            .prefix(5)
        
        return Array(jobEarnings)
    }
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(TISColors.gold)
                    
                    Text("Top Jobs")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                if topJobs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "briefcase")
                            .font(.system(size: 40))
                            .foregroundColor(TISColors.secondaryText)
                            .shimmer()
                        
                        Text("No jobs yet")
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                            .shimmer()
                    }
                    .frame(height: 100)
                } else {
                    VStack(spacing: 12) {
                        ForEach(Array(topJobs.indices), id: \.self) { index in
                            let jobEarning = topJobs[index]
                            let (job, earnings) = jobEarning
                            
                            HStack {
                                Text("\(index + 1).")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(TISColors.primary)
                                    .frame(width: 20, alignment: .leading)
                                
                                Text(job?.name ?? "Unknown Job")
                                    .font(.subheadline)
                                    .foregroundColor(TISColors.primaryText)
                                
                                Spacer()
                                
                                Text("$\(String(format: "%.2f", earnings))")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(TISColors.success)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func calculateTotalEarnings(for shifts: [Shift]) -> Double {
        shifts.reduce(0) { total, shift in
            let baseEarnings = calculateBaseEarnings(for: shift)
            let bonusEarnings = shift.bonusAmount
            return total + baseEarnings + bonusEarnings
        }
    }
    
    private func calculateBaseEarnings(for shift: Shift) -> Double {
        guard let job = shift.job else { return 0 }
        let hours = calculateDurationInHours(for: shift)
        let hourlyRate = job.hourlyRate
        
        switch shift.shiftType {
        case "Overtime":
            return hours * hourlyRate * 1.5
        case "Special Event":
            return hours * hourlyRate * 1.25
        default:
            return hours * hourlyRate
        }
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime,
              let endTime = shift.endTime else { return 0 }
        return endTime.timeIntervalSince(startTime) / 3600
    }
}

// MARK: - Insights Section

struct InsightsSection: View {
    let shifts: [Shift]
    @Binding var showingInsights: Bool
    
    var insights: [String] {
        var insightsList: [String] = []
        
        let totalEarnings = calculateTotalEarnings(for: shifts)
        let totalHours = calculateTotalHours(for: shifts)
        let averageHourlyRate = totalHours > 0 ? totalEarnings / totalHours : 0
        
        if totalEarnings > 1000 {
            insightsList.append("🎉 Great job! You've earned over $1,000 this period!")
        }
        
        if averageHourlyRate > 25 {
            insightsList.append("💰 Your average hourly rate is excellent at $\(String(format: "%.2f", averageHourlyRate))!")
        }
        
        if totalHours > 40 {
            insightsList.append("⏰ You've worked over 40 hours - consider taking a break!")
        }
        
        let overtimeShifts = shifts.filter { $0.shiftType == "Overtime" }
        if !overtimeShifts.isEmpty {
            insightsList.append("🔥 You've worked \(overtimeShifts.count) overtime shifts - great dedication!")
        }
        
        return insightsList
    }
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundColor(TISColors.warning)
                    
                    Text("Insights")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                    
                    Button(action: { showingInsights.toggle() }) {
                        Image(systemName: showingInsights ? "eye.slash.fill" : "eye.fill")
                            .font(.title3)
                            .foregroundColor(TISColors.primary)
                    }
                }
                
                if showingInsights && !insights.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(insights, id: \.self) { insight in
                            HStack(alignment: .top, spacing: 12) {
                                Text(insight)
                                    .font(.subheadline)
                                    .foregroundColor(TISColors.primaryText)
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } else if insights.isEmpty {
                    Text("Keep working to unlock insights!")
                        .font(.subheadline)
                        .foregroundColor(TISColors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else {
                    Text("Tap the eye icon to view insights")
                        .font(.subheadline)
                        .foregroundColor(TISColors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }
            }
        }
    }
    
    private func calculateTotalEarnings(for shifts: [Shift]) -> Double {
        shifts.reduce(0) { total, shift in
            let baseEarnings = calculateBaseEarnings(for: shift)
            let bonusEarnings = shift.bonusAmount
            return total + baseEarnings + bonusEarnings
        }
    }
    
    private func calculateTotalHours(for shifts: [Shift]) -> Double {
        shifts.reduce(0) { total, shift in
            total + calculateDurationInHours(for: shift)
        }
    }
    
    private func calculateBaseEarnings(for shift: Shift) -> Double {
        guard let job = shift.job else { return 0 }
        let hours = calculateDurationInHours(for: shift)
        let hourlyRate = job.hourlyRate
        
        switch shift.shiftType {
        case "Overtime":
            return hours * hourlyRate * 1.5
        case "Special Event":
            return hours * hourlyRate * 1.25
        default:
            return hours * hourlyRate
        }
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime,
              let endTime = shift.endTime else { return 0 }
        return endTime.timeIntervalSince(startTime) / 3600
    }
}

// MARK: - Job Filter Section

struct JobFilterSection: View {
    @Binding var selectedJob: Job?
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)],
        animation: .default)
    private var jobs: FetchedResults<Job>
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(.title2)
                        .foregroundColor(TISColors.info)
                    
                    Text("Filter by Job")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                if jobs.isEmpty {
                    // Beautiful empty state for jobs
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(TISColors.primary.opacity(0.1))
                                .frame(width: 60, height: 60)
                                .scaleEffect(1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: UUID())
                            
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 25, weight: .light))
                                .foregroundColor(TISColors.primary)
                                .scaleEffect(1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: UUID())
                        }
                        
                        Text("No jobs available")
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // All Jobs option
                            Button(action: { selectedJob = nil }) {
                                Text("All Jobs")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedJob == nil ? .white : TISColors.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedJob == nil ? TISColors.primary : TISColors.primary.opacity(0.1))
                                    .cornerRadius(20)
                            }
                            
                            ForEach(jobs, id: \.self) { job in
                                Button(action: { selectedJob = job }) {
                                    Text(job.name ?? "Unknown")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedJob == job ? .white : TISColors.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedJob == job ? TISColors.primary : TISColors.primary.opacity(0.1))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
        }
    }
}

// MARK: - Chart Data Point

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let label: String
}

#Preview {
    AnalyticsView()
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

// MARK: - AnalyticsInsightsSection

struct AnalyticsInsightsSection: View {
    let insights: [AnalyticsInsight]
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundColor(TISColors.warning)
                    
                    Text("Analytics Insights")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(insights) { insight in
                        InsightCard(insight: insight)
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

// MARK: - ChartTypeSelector

struct ChartTypeSelector: View {
    @Binding var selectedType: String
    let chartTypes: [String]
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Chart Type")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(TISColors.primaryText)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(chartTypes, id: \.self) { type in
                            Button(action: { selectedType = type }) {
                                Text(type)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedType == type ? .white : TISColors.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedType == type ? 
                                        TISColors.primary : 
                                        TISColors.primary.opacity(0.1)
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

// MARK: - AnalyticsFiltersView

struct AnalyticsFiltersView: View {
    @Binding var selectedPeriod: String
    @Binding var selectedJob: Job?
    let periods: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Time Period") {
                    ForEach(periods, id: \.self) { period in
                        Button(action: { selectedPeriod = period }) {
                            HStack {
                                Text(period)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedPeriod == period {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(TISColors.primary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
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

// MARK: - DetailedReportView

struct DetailedReportView: View {
    let shifts: [Shift]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    private func calculateTotalEarnings(for shift: Shift) -> Double {
        let baseEarnings = calculateBaseEarnings(for: shift)
        let bonusEarnings = shift.bonusAmount
        return baseEarnings + bonusEarnings
    }
    
    private func calculateBaseEarnings(for shift: Shift) -> Double {
        guard let job = shift.job,
              let startTime = shift.startTime,
              let endTime = shift.endTime else { return 0 }
        
        let duration = endTime.timeIntervalSince(startTime) / 3600 // hours
        let hourlyRate = job.hourlyRate
        
        return duration * hourlyRate
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime,
              let endTime = shift.endTime else { return 0 }
        return endTime.timeIntervalSince(startTime) / 3600
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Summary
                    TISCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Summary")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            let totalEarnings = shifts.reduce(0.0) { total, shift in
                                total + calculateTotalEarnings(for: shift)
                            }
                            let totalHours = shifts.reduce(0.0) { total, shift in
                                total + calculateDurationInHours(for: shift)
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Total Earnings")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(localizationManager.formatCurrency(totalEarnings))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("Total Hours")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "%.1f", totalHours))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                    }
                    
                    // Shifts List
                    ForEach(shifts, id: \.id) { shift in
                        ShiftReportRow(shift: shift)
                    }
                }
                .padding()
            }
            .navigationTitle("Detailed Report")
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

struct ShiftReportRow: View {
    let shift: Shift
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        TISCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(shift.job?.name ?? "Unknown Job")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if let startTime = shift.startTime, let endTime = shift.endTime {
                        Text("\(startTime.formatted(.dateTime.hour().minute())) - \(endTime.formatted(.dateTime.hour().minute()))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(localizationManager.formatCurrency(calculateTotalEarnings(for: shift)))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(TISColors.primary)
                    
                    Text(String(format: "%.1f hrs", calculateDurationInHours(for: shift)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func calculateTotalEarnings(for shift: Shift) -> Double {
        let baseEarnings = calculateBaseEarnings(for: shift)
        let bonusEarnings = shift.bonusAmount
        return baseEarnings + bonusEarnings
    }
    
    private func calculateBaseEarnings(for shift: Shift) -> Double {
        guard let job = shift.job,
              let startTime = shift.startTime,
              let endTime = shift.endTime else { return 0 }
        
        let duration = endTime.timeIntervalSince(startTime) / 3600 // hours
        let hourlyRate = job.hourlyRate
        
        return duration * hourlyRate
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime,
              let endTime = shift.endTime else { return 0 }
        return endTime.timeIntervalSince(startTime) / 3600
    }
}