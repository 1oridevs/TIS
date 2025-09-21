import SwiftUI
import CoreData
import Charts

struct AnalyticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Shift.startTime, ascending: false)],
        predicate: NSPredicate(format: "isActive == NO"),
        animation: .default)
    private var shifts: FetchedResults<Shift>
    
    @State private var selectedPeriod = "This Month"
    @State private var selectedJob: Job?
    @State private var showingInsights = false
    @State private var isAnimating = false
    
    let periods = ["This Week", "This Month", "Last 3 Months", "This Year", "All Time"]
    
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
                    
                    // Earnings Chart
                    EarningsChartView(shifts: filteredShifts, period: selectedPeriod)
                    
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
            .background(TISColors.background)
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingInsights.toggle() }) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(TISColors.primary)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                isAnimating = true
            }
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
                    VStack(spacing: 12) {
                        Image(systemName: "chart.line.downtrend.xyaxis")
                            .font(.system(size: 40))
                            .foregroundColor(TISColors.secondaryText)
                        
                        Text("No data available")
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
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
                        
                        Text("No data available")
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
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
                        
                        Text("No jobs yet")
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
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
                    Text("No jobs available")
                        .font(.subheadline)
                        .foregroundColor(TISColors.secondaryText)
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