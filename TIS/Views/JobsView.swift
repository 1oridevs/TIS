import SwiftUI
import CoreData

struct JobsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var localizationManager: LocalizationManager
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)],
        animation: .default)
    private var jobs: FetchedResults<Job>
    
    
    @State private var showingAddJob = false
    @State private var jobToEdit: Job?
    
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
                
                if jobs.isEmpty {
                    // Beautiful empty state
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(TISColors.primary.opacity(0.1))
                                .frame(width: 120, height: 120)
                                .scaleEffect(1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: UUID())
                            
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(TISColors.primary)
                                .scaleEffect(1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: UUID())
                        }
                        
                        VStack(spacing: 12) {
                            Text("No Jobs Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                                .multilineTextAlignment(.center)
                            
                            Text("Add your first job to start tracking your time and earnings.")
                                .font(.body)
                                .foregroundColor(TISColors.secondaryText)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }
                        
                        Button(action: { showingAddJob = true }) {
                            HStack {
                                Text("Add Job")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
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
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 40)
                } else {
                    List {
                        ForEach(jobs, id: \.id) { job in
                            JobDetailRowView(job: job) {
                                jobToEdit = job
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteJobs)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
            .navigationTitle(localizationManager.localizedString(for: "jobs.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddJob = true }) {
                        Image(systemName: "plus")
                    }
                }
            })
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
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.name ?? "Unknown Job")
                        .font(.headline)
                    
                    Text("\(localizationManager.formatCurrency(job.hourlyRate))/hour")
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
                    title: localizationManager.localizedString(for: "jobs.total_hours"),
                    value: String(format: "%.1fh", calculateTotalHours(for: job))
                )
                
                StatisticView(
                    title: localizationManager.localizedString(for: "jobs.total_earnings"),
                    value: localizationManager.formatCurrency(calculateTotalEarnings(for: job))
                )
                
                StatisticView(
                    title: localizationManager.localizedString(for: "jobs.shifts_count"),
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
                            Text(localizationManager.formatCurrency(bonus.amount))
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
    
    private func calculateTotalHours(for job: Job) -> Double {
        guard let shifts = job.shifts?.allObjects as? [Shift] else { return 0 }
        return shifts.reduce(0.0) { total, shift in
            total + calculateDurationInHours(for: shift)
        }
    }
    
    private func calculateTotalEarnings(for job: Job) -> Double {
        guard let shifts = job.shifts?.allObjects as? [Shift] else { return 0 }
        return shifts.reduce(0.0) { total, shift in
            total + calculateShiftEarnings(for: shift, job: job)
        }
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime else { return 0 }
        let endTime = shift.endTime ?? Date()
        return endTime.timeIntervalSince(startTime) / 3600
    }
    
    private func calculateShiftEarnings(for shift: Shift, job: Job) -> Double {
        let duration = calculateDurationInHours(for: shift)
        let baseEarnings = duration * job.hourlyRate
        let bonusAmount = shift.bonusAmount 
        return baseEarnings + bonusAmount
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
