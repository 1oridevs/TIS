import SwiftUI
import CoreData

struct AddJobView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var jobName = ""
    @State private var hourlyRate = ""
    @State private var bonuses: [BonusInput] = []
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Job Details") {
                    TextField("Job Name", text: $jobName)
                    
                    HStack {
                        Text("Hourly Rate")
                        Spacer()
                        TextField("0.00", text: $hourlyRate)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Bonuses") {
                    ForEach(bonuses.indices, id: \.self) { index in
                        HStack {
                            TextField("Bonus Name", text: $bonuses[index].name)
                            
                            TextField("Amount", text: $bonuses[index].amount)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .onDelete(perform: deleteBonus)
                    
                    Button("Add Bonus") {
                        bonuses.append(BonusInput(name: "", amount: ""))
                    }
                }
            }
            .navigationTitle("Add Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveJob()
                    }
                    .disabled(jobName.isEmpty || hourlyRate.isEmpty)
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveJob() {
        guard !jobName.isEmpty,
              let rate = Double(hourlyRate),
              rate > 0 else {
            errorMessage = "Please enter a valid job name and hourly rate"
            showingError = true
            return
        }
        
        let job = Job(context: viewContext)
        job.id = UUID()
        job.name = jobName
        job.hourlyRate = rate
        job.createdAt = Date()
        
        // Add bonuses
        for bonusInput in bonuses {
            if !bonusInput.name.isEmpty,
               let amount = Double(bonusInput.amount),
               amount > 0 {
                let bonus = Bonus(context: viewContext)
                bonus.id = UUID()
                bonus.name = bonusInput.name
                bonus.amount = amount
                bonus.job = job
            }
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save job: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func deleteBonus(offsets: IndexSet) {
        bonuses.remove(atOffsets: offsets)
    }
}

struct EditJobView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let job: Job
    
    @State private var jobName: String
    @State private var hourlyRate: String
    @State private var bonuses: [BonusInput] = []
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(job: Job) {
        self.job = job
        self._jobName = State(initialValue: job.name ?? "")
        self._hourlyRate = State(initialValue: String(job.hourlyRate))
        
        // Load existing bonuses
        if let existingBonuses = job.bonuses?.allObjects as? [Bonus] {
            self._bonuses = State(initialValue: existingBonuses.map { 
                BonusInput(name: $0.name ?? "", amount: String($0.amount))
            })
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Job Details") {
                    TextField("Job Name", text: $jobName)
                    
                    HStack {
                        Text("Hourly Rate")
                        Spacer()
                        TextField("0.00", text: $hourlyRate)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Bonuses") {
                    ForEach(bonuses.indices, id: \.self) { index in
                        HStack {
                            TextField("Bonus Name", text: $bonuses[index].name)
                            
                            TextField("Amount", text: $bonuses[index].amount)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .onDelete(perform: deleteBonus)
                    
                    Button("Add Bonus") {
                        bonuses.append(BonusInput(name: "", amount: ""))
                    }
                }
            }
            .navigationTitle("Edit Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveJob()
                    }
                    .disabled(jobName.isEmpty || hourlyRate.isEmpty)
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveJob() {
        guard !jobName.isEmpty,
              let rate = Double(hourlyRate),
              rate > 0 else {
            errorMessage = "Please enter a valid job name and hourly rate"
            showingError = true
            return
        }
        
        job.name = jobName
        job.hourlyRate = rate
        
        // Clear existing bonuses
        if let existingBonuses = job.bonuses?.allObjects as? [Bonus] {
            for bonus in existingBonuses {
                viewContext.delete(bonus)
            }
        }
        
        // Add new bonuses
        for bonusInput in bonuses {
            if !bonusInput.name.isEmpty,
               let amount = Double(bonusInput.amount),
               amount > 0 {
                let bonus = Bonus(context: viewContext)
                bonus.id = UUID()
                bonus.name = bonusInput.name
                bonus.amount = amount
                bonus.job = job
            }
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save job: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func deleteBonus(offsets: IndexSet) {
        bonuses.remove(atOffsets: offsets)
    }
}

struct BonusInput {
    var name: String
    var amount: String
}

#Preview {
    AddJobView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
