import SwiftUI
import CoreData

struct JobsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)],
        animation: .default)
    private var jobs: FetchedResults<Job>
    
    @State private var showingAddJob = false
    @State private var jobToEdit: Job?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(jobs, id: \.id) { job in
                    JobDetailRowView(job: job) {
                        jobToEdit = job
                    }
                }
                .onDelete(perform: deleteJobs)
            }
            .navigationTitle("Jobs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddJob = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddJob) {
            AddJobView()
        }
        .sheet(item: $jobToEdit) { job in
            EditJobView(job: job)
        }
    }
    
    private func deleteJobs(offsets: IndexSet) {
        withAnimation {
            offsets.map { jobs[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Handle error
            }
        }
    }
}

struct JobDetailRowView: View {
    let job: Job
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.name ?? "Unknown Job")
                        .font(.headline)
                    
                    Text(String(format: "$%.2f/hour", job.hourlyRate))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
            }
            
            // Statistics
            HStack(spacing: 20) {
                StatisticView(
                    title: "Total Hours",
                    value: String(format: "%.1fh", job.totalHoursWorked)
                )
                
                StatisticView(
                    title: "Total Earnings",
                    value: String(format: "$%.2f", job.totalEarnings)
                )
                
                StatisticView(
                    title: "Shifts",
                    value: "\(job.shifts?.count ?? 0)"
                )
            }
            
            // Bonuses
            if let bonuses = job.bonuses?.allObjects as? [Bonus], !bonuses.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bonuses")
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
        .padding(.vertical, 8)
    }
}

struct StatisticView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    JobsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
