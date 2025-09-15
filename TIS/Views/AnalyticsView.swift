import SwiftUI
import CoreData

struct AnalyticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Shift.startTime, ascending: false)],
        predicate: NSPredicate(format: "isActive == NO"),
        animation: .default)
    private var shifts: FetchedResults<Shift>
    
    @State private var selectedPeriod = "This Month"
    @State private var selectedJob: Job?
    
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
        filteredShifts.reduce(0) { $0 + $1.totalEarnings }
    }
    
    var totalHours: Double {
        filteredShifts.reduce(0) { $0 + $1.durationInHours }
    }
    
    var averageHourlyRate: Double {
        guard totalHours > 0 else { return 0 }
        return totalEarnings / totalHours
    }
    
    var earningsByType: (regular: Double, overtime: Double, special: Double, bonus: Double) {
        return filteredShifts.reduce((0, 0, 0, 0)) { total, shift in
            let breakdown = shift.earningsBreakdown
            return (
                regular: total.0 + breakdown.regular,
                overtime: total.1 + breakdown.overtime,
                special: total.2 + breakdown.special,
                bonus: total.3 + breakdown.bonus
            )
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Period and Job Selector
                    SelectorSection()
                    
                    // Summary Cards
                    SummaryCardsSection()
                    
                    // Earnings Breakdown
                    EarningsBreakdownSection()
                    
                    // Charts Section
                    ChartsSection()
                    
                    // Top Jobs
                    TopJobsSection()
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    @ViewBuilder
    private func SelectorSection() -> some View {
        VStack(spacing: 16) {
            // Period Selector
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
            
            // Job Filter
            if !shifts.isEmpty {
                JobFilterView(selectedJob: $selectedJob)
            }
        }
    }
    
    @ViewBuilder
    private func SummaryCardsSection() -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
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
                title: "Avg Hourly Rate",
                value: String(format: "$%.2f/h", averageHourlyRate),
                icon: "chart.line.uptrend.xyaxis",
                color: .orange
            )
            
            SummaryCard(
                title: "Shifts",
                value: "\(filteredShifts.count)",
                icon: "briefcase.fill",
                color: .purple
            )
        }
    }
    
    @ViewBuilder
    private func EarningsBreakdownSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Earnings Breakdown")
                .font(.headline)
            
            VStack(spacing: 12) {
                EarningsBreakdownRow(
                    title: "Regular Pay",
                    amount: earningsByType.regular,
                    color: .blue,
                    icon: "clock"
                )
                
                EarningsBreakdownRow(
                    title: "Overtime Pay",
                    amount: earningsByType.overtime,
                    color: .orange,
                    icon: "clock.badge.exclamationmark"
                )
                
                EarningsBreakdownRow(
                    title: "Special Events",
                    amount: earningsByType.special,
                    color: .purple,
                    icon: "star.fill"
                )
                
                EarningsBreakdownRow(
                    title: "Bonuses",
                    amount: earningsByType.bonus,
                    color: .green,
                    icon: "gift.fill"
                )
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private func ChartsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Earnings Trend")
                .font(.headline)
            
            // Simple bar chart representation
            VStack(spacing: 8) {
                ForEach(Array(earningsByType.enumerated()), id: \.offset) { index, earnings in
                    let titles = ["Regular", "Overtime", "Special", "Bonus"]
                    let colors: [Color] = [.blue, .orange, .purple, .green]
                    let maxEarnings = max(earningsByType.regular, earningsByType.overtime, earningsByType.special, earningsByType.bonus)
                    
                    if maxEarnings > 0 {
                        HStack {
                            Text(titles[index])
                                .font(.caption)
                                .frame(width: 60, alignment: .leading)
                            
                            GeometryReader { geometry in
                                HStack {
                                    Rectangle()
                                        .fill(colors[index])
                                        .frame(width: geometry.size.width * (earnings / maxEarnings))
                                    
                                    Spacer()
                                }
                            }
                            .frame(height: 20)
                            
                            Text(String(format: "$%.0f", earnings))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private func TopJobsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Earning Jobs")
                .font(.headline)
            
            let jobEarnings = Dictionary(grouping: filteredShifts) { $0.job }
                .mapValues { shifts in
                    shifts.reduce(0) { $0 + $1.totalEarnings }
                }
                .sorted { $0.value > $1.value }
                .prefix(5)
            
            if jobEarnings.isEmpty {
                Text("No data available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(Array(jobEarnings.enumerated()), id: \.offset) { index, jobEarning in
                    HStack {
                        Text("\(index + 1).")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Text(jobEarning.key?.name ?? "Unknown Job")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(String(format: "$%.2f", jobEarning.value))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct JobFilterView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)],
        animation: .default)
    private var jobs: FetchedResults<Job>
    
    @Binding var selectedJob: Job?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button(action: { selectedJob = nil }) {
                    Text("All Jobs")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedJob == nil ? Color.blue : Color(.systemGray5))
                        .foregroundColor(selectedJob == nil ? .white : .primary)
                        .cornerRadius(16)
                }
                
                ForEach(jobs, id: \.id) { job in
                    Button(action: { selectedJob = job }) {
                        Text(job.name ?? "Unknown")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedJob?.id == job.id ? Color.blue : Color(.systemGray5))
                            .foregroundColor(selectedJob?.id == job.id ? .white : .primary)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct EarningsBreakdownRow: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(String(format: "$%.2f", amount))
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    AnalyticsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
