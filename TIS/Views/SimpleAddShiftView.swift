import SwiftUI
import CoreData

struct SimpleAddShiftView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedJob: Job?
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(8 * 3600)
    @State private var notes = ""
    @State private var bonusAmount = 0.0
    
    let jobs: FetchedResults<Job>
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Job Details")) {
                    Picker("Job", selection: $selectedJob) {
                        Text("Select Job").tag(nil as Job?)
                        ForEach(jobs, id: \.id) { job in
                            Text(job.name ?? "Unknown Job").tag(job as Job?)
                        }
                    }
                }
                
                Section(header: Text("Time Details")) {
                    DatePicker("Start Time", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End Time", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
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
        }
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
        
        // Auto-detect shift type
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

#Preview {
    SimpleAddShiftView(jobs: FetchedResults<Job>())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
