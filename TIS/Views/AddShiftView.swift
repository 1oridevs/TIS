import SwiftUI
import CoreData

struct AddShiftView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedJob: Job?
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(8 * 3600) // 8 hours later
    @State private var notes = ""
    @State private var bonusAmount = 0.0
    @State private var showingJobPicker = false
    
    let jobs: FetchedResults<Job>
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Job Details")) {
                    HStack {
                        Text("Job")
                        Spacer()
                        Button(selectedJob?.name ?? "Select Job") {
                            showingJobPicker = true
                        }
                        .foregroundColor(selectedJob == nil ? .red : .blue)
                    }
                }
                
                Section(header: Text("Time Details")) {
                    DatePicker("Start Time", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    
                    DatePicker("End Time", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(formatDuration(endDate.timeIntervalSince(startDate)))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Additional Details")) {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                    
                    HStack {
                        Text("Bonus Amount")
                        Spacer()
                        TextField("0.00", value: $bonusAmount, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Earnings Preview")) {
                    if let job = selectedJob {
                        let duration = endDate.timeIntervalSince(startDate)
                        let hours = duration / 3600
                        let baseEarnings = hours * job.hourlyRate
                        let totalEarnings = baseEarnings + bonusAmount
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Base Pay (\(String(format: "%.1f", hours)) hours)")
                                Spacer()
                                Text(String(format: "$%.2f", baseEarnings))
                            }
                            
                            if bonusAmount > 0 {
                                HStack {
                                    Text("Bonus")
                                    Spacer()
                                    Text(String(format: "$%.2f", bonusAmount))
                                        .foregroundColor(.green)
                                }
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total Earnings")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(String(format: "$%.2f", totalEarnings))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Add Manual Shift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveShift()
                    }
                    .disabled(selectedJob == nil || startDate >= endDate)
                }
            }
            .sheet(isPresented: $showingJobPicker) {
                JobPickerView(selectedJob: $selectedJob, jobs: jobs)
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return String(format: "%d:%02d", hours, minutes)
    }
    
    private func saveShift() {
        guard let job = selectedJob else { return }
        
        let shift = Shift(context: viewContext)
        shift.id = UUID()
        shift.job = job
        shift.startTime = startDate
        shift.endTime = endDate
        shift.isActive = false
        shift.notes = notes.isEmpty ? nil : notes
        shift.bonusAmount = bonusAmount
        
        // Auto-detect shift type based on duration and time
        let duration = endDate.timeIntervalSince(startDate)
        let hours = duration / 3600
        
        if hours > 8 {
            shift.shiftType = "Overtime"
        } else if hours >= 6 {
            shift.shiftType = "Regular"
        } else {
            shift.shiftType = "Flexible"
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving shift: \(error)")
        }
    }
}

struct JobPickerView: View {
    @Binding var selectedJob: Job?
    let jobs: FetchedResults<Job>
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
                            VStack(alignment: .leading) {
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
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddShiftView(jobs: FetchedResults<Job>())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
