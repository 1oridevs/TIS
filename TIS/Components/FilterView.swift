import SwiftUI
import CoreData

// MARK: - Filter View

struct FilterView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @Binding var isPresented: Bool
    @Binding var filters: ShiftFilters
    let onApplyFilters: () -> Void
    
    @State private var tempFilters: ShiftFilters
    
    init(isPresented: Binding<Bool>, filters: Binding<ShiftFilters>, onApplyFilters: @escaping () -> Void) {
        self._isPresented = isPresented
        self._filters = filters
        self.onApplyFilters = onApplyFilters
        self._tempFilters = State(initialValue: filters.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Options
                ScrollView {
                    VStack(spacing: 24) {
                        // Date Range Filter
                        DateRangeFilterSection(filters: $tempFilters)
                        
                        // Job Filter
                        JobFilterSection(filters: $tempFilters)
                        
                        // Shift Type Filter
                        ShiftTypeFilterSection(filters: $tempFilters)
                        
                        // Earnings Range Filter
                        EarningsRangeFilterSection(filters: $tempFilters)
                        
                        // Duration Filter
                        DurationFilterSection(filters: $tempFilters)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: applyFilters) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Apply Filters")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(TISColors.primary)
                        .cornerRadius(12)
                    }
                    
                    Button(action: clearFilters) {
                        HStack {
                            Image(systemName: "xmark")
                            Text("Clear All")
                        }
                        .font(.headline)
                        .foregroundColor(TISColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(TISColors.primary.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationTitle("Filter Shifts")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Reset") {
                    resetFilters()
                }
            )
        }
    }
    
    private func applyFilters() {
        filters = tempFilters
        onApplyFilters()
        isPresented = false
    }
    
    private func clearFilters() {
        tempFilters = ShiftFilters()
    }
    
    private func resetFilters() {
        tempFilters = ShiftFilters()
    }
}

// MARK: - Shift Filters

struct ShiftFilters {
    var dateRange: DateRangeFilter = .all
    var selectedJobs: Set<Job> = []
    var shiftTypes: Set<String> = []
    var earningsRange: ClosedRange<Double> = 0...10000
    var durationRange: ClosedRange<Double> = 0...24
    var sortBy: SortOption = .date
    var sortOrder: SortOrder = .descending
    
    enum DateRangeFilter {
        case all
        case today
        case thisWeek
        case thisMonth
        case last30Days
        case custom(Date, Date)
    }
    
    enum SortOption: String, CaseIterable {
        case date = "Date"
        case earnings = "Earnings"
        case duration = "Duration"
        case job = "Job"
    }
    
    enum SortOrder: String, CaseIterable {
        case ascending = "Ascending"
        case descending = "Descending"
    }
}

// MARK: - Filter Sections

struct DateRangeFilterSection: View {
    @Binding var filters: ShiftFilters
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date Range")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach([
                    (ShiftFilters.DateRangeFilter.today, "Today"),
                    (ShiftFilters.DateRangeFilter.thisWeek, "This Week"),
                    (ShiftFilters.DateRangeFilter.thisMonth, "This Month"),
                    (ShiftFilters.DateRangeFilter.last30Days, "Last 30 Days"),
                    (ShiftFilters.DateRangeFilter.all, "All Time")
                ], id: \.0) { filter, title in
                    Button(action: {
                        filters.dateRange = filter
                    }) {
                        HStack {
                            Text(title)
                                .foregroundColor(.primary)
                            Spacer()
                            if filters.dateRange == filter {
                                Image(systemName: "checkmark")
                                    .foregroundColor(TISColors.primary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
}

struct JobFilterSection: View {
    @Binding var filters: ShiftFilters
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)],
        animation: .default)
    private var jobs: FetchedResults<Job>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Jobs")
                .font(.headline)
                .foregroundColor(.primary)
            
            if jobs.isEmpty {
                Text("No jobs available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(jobs, id: \.id) { job in
                        Button(action: {
                            if filters.selectedJobs.contains(job) {
                                filters.selectedJobs.remove(job)
                            } else {
                                filters.selectedJobs.insert(job)
                            }
                        }) {
                            HStack {
                                Text(job.name ?? "Unknown Job")
                                    .foregroundColor(.primary)
                                Spacer()
                                if filters.selectedJobs.contains(job) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(TISColors.primary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
    }
}

struct ShiftTypeFilterSection: View {
    @Binding var filters: ShiftFilters
    
    private let shiftTypes = ["Regular", "Overtime", "Special Event", "Flexible"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shift Types")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(shiftTypes, id: \.self) { type in
                    Button(action: {
                        if filters.shiftTypes.contains(type) {
                            filters.shiftTypes.remove(type)
                        } else {
                            filters.shiftTypes.insert(type)
                        }
                    }) {
                        HStack {
                            Text(type)
                                .foregroundColor(.primary)
                            Spacer()
                            if filters.shiftTypes.contains(type) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(TISColors.primary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
}

struct EarningsRangeFilterSection: View {
    @Binding var filters: ShiftFilters
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Earnings Range")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                HStack {
                    Text("$\(Int(filters.earningsRange.lowerBound))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(Int(filters.earningsRange.upperBound))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Custom range slider would go here
                Text("Range: $\(String(format: "%.2f", filters.earningsRange.lowerBound)) - $\(String(format: "%.2f", filters.earningsRange.upperBound))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct DurationFilterSection: View {
    @Binding var filters: ShiftFilters
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Duration Range")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                HStack {
                    Text("\(String(format: "%.1f", filters.durationRange.lowerBound))h")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(String(format: "%.1f", filters.durationRange.upperBound))h")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("Range: \(String(format: "%.1f", filters.durationRange.lowerBound))h - \(String(format: "%.1f", filters.durationRange.upperBound))h")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Filter Helper

class FilterHelper {
    static func applyFilters(to shifts: [Shift], filters: ShiftFilters) -> [Shift] {
        var filteredShifts = shifts
        
        // Apply date range filter
        filteredShifts = applyDateRangeFilter(filteredShifts, filter: filters.dateRange)
        
        // Apply job filter
        if !filters.selectedJobs.isEmpty {
            filteredShifts = filteredShifts.filter { shift in
                guard let job = shift.job else { return false }
                return filters.selectedJobs.contains(job)
            }
        }
        
        // Apply shift type filter
        if !filters.shiftTypes.isEmpty {
            filteredShifts = filteredShifts.filter { shift in
                guard let shiftType = shift.shiftType else { return false }
                return filters.shiftTypes.contains(shiftType)
            }
        }
        
        // Apply earnings range filter
        filteredShifts = filteredShifts.filter { shift in
            let earnings = calculateTotalEarnings(for: shift)
            return filters.earningsRange.contains(earnings)
        }
        
        // Apply duration filter
        filteredShifts = filteredShifts.filter { shift in
            let duration = calculateDurationInHours(for: shift)
            return filters.durationRange.contains(duration)
        }
        
        // Apply sorting
        filteredShifts = applySorting(filteredShifts, sortBy: filters.sortBy, order: filters.sortOrder)
        
        return filteredShifts
    }
    
    private static func applyDateRangeFilter(_ shifts: [Shift], filter: ShiftFilters.DateRangeFilter) -> [Shift] {
        let calendar = Calendar.current
        let now = Date()
        
        switch filter {
        case .all:
            return shifts
        case .today:
            return shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return calendar.isDate(startTime, inSameDayAs: now)
            }
        case .thisWeek:
            return shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return calendar.isDate(startTime, equalTo: now, toGranularity: .weekOfYear)
            }
        case .thisMonth:
            return shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return calendar.isDate(startTime, equalTo: now, toGranularity: .month)
            }
        case .last30Days:
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            return shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return startTime >= thirtyDaysAgo
            }
        case .custom(let startDate, let endDate):
            return shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return startTime >= startDate && startTime <= endDate
            }
        }
    }
    
    private static func applySorting(_ shifts: [Shift], sortBy: ShiftFilters.SortOption, order: ShiftFilters.SortOrder) -> [Shift] {
        let sortedShifts = shifts.sorted { shift1, shift2 in
            let comparison: ComparisonResult
            
            switch sortBy {
            case .date:
                let date1 = shift1.startTime ?? Date.distantPast
                let date2 = shift2.startTime ?? Date.distantPast
                comparison = date1.compare(date2)
            case .earnings:
                let earnings1 = calculateTotalEarnings(for: shift1)
                let earnings2 = calculateTotalEarnings(for: shift2)
                comparison = earnings1 < earnings2 ? .orderedAscending : .orderedDescending
            case .duration:
                let duration1 = calculateDurationInHours(for: shift1)
                let duration2 = calculateDurationInHours(for: shift2)
                comparison = duration1 < duration2 ? .orderedAscending : .orderedDescending
            case .job:
                let job1 = shift1.job?.name ?? ""
                let job2 = shift2.job?.name ?? ""
                comparison = job1.compare(job2)
            }
            
            return order == .ascending ? comparison == .orderedAscending : comparison == .orderedDescending
        }
        
        return sortedShifts
    }
    
    private static func calculateTotalEarnings(for shift: Shift) -> Double {
        // Placeholder - implement actual earnings calculation
        return 0.0
    }
    
    private static func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime else { return 0 }
        let endTime = shift.endTime ?? Date()
        return endTime.timeIntervalSince(startTime) / 3600
    }
}

// MARK: - Preview

#Preview {
    FilterView(
        isPresented: .constant(true),
        filters: .constant(ShiftFilters()),
        onApplyFilters: {}
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
