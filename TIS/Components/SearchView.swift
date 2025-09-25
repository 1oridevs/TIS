import SwiftUI
import CoreData

// MARK: - Search View

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var searchText = ""
    @State private var searchScope: SearchScope = .all
    @State private var searchResults: [SearchResult] = []
    @State private var isSearching = false
    
    enum SearchScope: String, CaseIterable {
        case all = "All"
        case jobs = "Jobs"
        case shifts = "Shifts"
        case notes = "Notes"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBarView(
                    searchText: $searchText,
                    searchScope: $searchScope,
                    onSearchTextChanged: performSearch
                )
                
                // Search Results
                if isSearching {
                    SearchResultsView(
                        results: searchResults,
                        searchText: searchText,
                        onResultTapped: handleResultTap
                    )
                } else if searchText.isEmpty {
                    SearchEmptyStateView()
                } else {
                    NoSearchResultsView()
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
        .onChange(of: searchText) { _ in
            performSearch()
        }
        .onChange(of: searchScope) { _ in
            performSearch()
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let results = searchInData(searchText: searchText, scope: searchScope)
            
            DispatchQueue.main.async {
                self.searchResults = results
                self.isSearching = false
            }
        }
    }
    
    private func searchInData(searchText: String, scope: SearchScope) -> [SearchResult] {
        var results: [SearchResult] = []
        let searchTextLower = searchText.lowercased()
        
        // Search Jobs
        if scope == .all || scope == .jobs {
            let jobsRequest: NSFetchRequest<Job> = Job.fetchRequest()
            jobsRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
            
            do {
                let jobs = try viewContext.fetch(jobsRequest)
                for job in jobs {
                    results.append(SearchResult(
                        id: job.id?.uuidString ?? UUID().uuidString,
                        type: .job,
                        title: job.name ?? "Unknown Job",
                        subtitle: "Hourly Rate: $\(String(format: "%.2f", job.hourlyRate))",
                        detail: "Total Earnings: $\(String(format: "%.2f", calculateJobTotalEarnings(job)))",
                        object: job
                    ))
                }
            } catch {
                print("Error searching jobs: \(error)")
            }
        }
        
        // Search Shifts
        if scope == .all || scope == .shifts {
            let shiftsRequest: NSFetchRequest<Shift> = Shift.fetchRequest()
            shiftsRequest.predicate = NSPredicate(format: "isActive == NO")
            
            do {
                let shifts = try viewContext.fetch(shiftsRequest)
                for shift in shifts {
                    if let jobName = shift.job?.name, jobName.lowercased().contains(searchTextLower) ||
                       let shiftType = shift.shiftType, shiftType.lowercased().contains(searchTextLower) {
                        results.append(SearchResult(
                            id: shift.id?.uuidString ?? UUID().uuidString,
                            type: .shift,
                            title: "\(shift.job?.name ?? "Unknown") - \(shift.shiftType ?? "Regular")",
                            subtitle: formatShiftDate(shift.startTime),
                            detail: "Duration: \(String(format: "%.2f", calculateDurationInHours(shift))) hours",
                            object: shift
                        ))
                    }
                }
            } catch {
                print("Error searching shifts: \(error)")
            }
        }
        
        // Search Notes
        if scope == .all || scope == .notes {
            let shiftsRequest: NSFetchRequest<Shift> = Shift.fetchRequest()
            shiftsRequest.predicate = NSPredicate(format: "notes CONTAINS[cd] %@", searchText)
            
            do {
                let shifts = try viewContext.fetch(shiftsRequest)
                for shift in shifts {
                    results.append(SearchResult(
                        id: shift.id?.uuidString ?? UUID().uuidString,
                        type: .note,
                        title: "\(shift.job?.name ?? "Unknown") - \(formatShiftDate(shift.startTime))",
                        subtitle: "Notes: \(shift.notes ?? "")",
                        detail: "Duration: \(String(format: "%.2f", calculateDurationInHours(shift))) hours",
                        object: shift
                    ))
                }
            } catch {
                print("Error searching notes: \(error)")
            }
        }
        
        return results
    }
    
    private func handleResultTap(_ result: SearchResult) {
        // Handle navigation based on result type
        switch result.type {
        case .job:
            // Navigate to job details
            break
        case .shift:
            // Navigate to shift details
            break
        case .note:
            // Navigate to shift details
            break
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateJobTotalEarnings(_ job: Job) -> Double {
        // Calculate total earnings for a job
        return 0.0 // Placeholder
    }
    
    private func calculateDurationInHours(_ shift: Shift) -> Double {
        guard let startTime = shift.startTime else { return 0 }
        let endTime = shift.endTime ?? Date()
        return endTime.timeIntervalSince(startTime) / 3600
    }
    
    private func formatShiftDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        return date.formatted(.dateTime.month().day().hour().minute())
    }
}

// MARK: - Search Result

struct SearchResult: Identifiable {
    let id: String
    let type: SearchResultType
    let title: String
    let subtitle: String
    let detail: String
    let object: Any
    
    enum SearchResultType {
        case job
        case shift
        case note
    }
}

// MARK: - Search Bar View

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var searchScope: SearchView.SearchScope
    let onSearchTextChanged: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Search Text Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search jobs, shifts, notes...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        onSearchTextChanged()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        onSearchTextChanged()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Search Scope Picker
            Picker("Search Scope", selection: $searchScope) {
                ForEach(SearchView.SearchScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Search Results View

struct SearchResultsView: View {
    let results: [SearchResult]
    let searchText: String
    let onResultTapped: (SearchResult) -> Void
    
    var body: some View {
        List {
            ForEach(results) { result in
                SearchResultRowView(
                    result: result,
                    searchText: searchText,
                    onTap: onResultTapped
                )
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Search Result Row View

struct SearchResultRowView: View {
    let result: SearchResult
    let searchText: String
    let onTap: (SearchResult) -> Void
    
    var body: some View {
        Button(action: {
            onTap(result)
        }) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: iconForResultType(result.type))
                    .font(.title2)
                    .foregroundColor(colorForResultType(result.type))
                    .frame(width: 30, height: 30)
                    .background(colorForResultType(result.type).opacity(0.1))
                    .cornerRadius(8)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(result.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text(result.detail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForResultType(_ type: SearchResult.SearchResultType) -> String {
        switch type {
        case .job:
            return "briefcase.fill"
        case .shift:
            return "clock.fill"
        case .note:
            return "note.text"
        }
    }
    
    private func colorForResultType(_ type: SearchResult.SearchResultType) -> Color {
        switch type {
        case .job:
            return .blue
        case .shift:
            return .green
        case .note:
            return .orange
        }
    }
}

// MARK: - Empty States

struct SearchEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Search Your Data")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Search through your jobs, shifts, and notes to find what you're looking for.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoSearchResultsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Results Found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Try adjusting your search criteria or check your spelling.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    SearchView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
