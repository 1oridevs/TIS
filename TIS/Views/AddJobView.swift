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
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .info
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(TISColors.primaryGradient)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Add New Job")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Text("Create a new work position to track")
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Job Details Card
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(TISColors.primary)
                                .font(.title3)
                            
                            Text("Job Information")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Job Name")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(TISColors.primaryText)
                                
                                TextField("Enter job title", text: $jobName)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Hourly Rate")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(TISColors.primaryText)
                                
                                HStack {
                                    Text("$")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(TISColors.primary)
                                    
                                    TextField("0.00", text: $hourlyRate)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(TISColors.cardGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(TISColors.cardBorder.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .tisShadow(TISShadows.medium)
                    
                    // Bonuses Card
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(TISColors.warning)
                                .font(.title3)
                            
                            Text("Bonuses (Optional)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Spacer()
                            
                            Button(action: {
                                bonuses.append(BonusInput(name: "", amount: ""))
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(TISColors.primary)
                            }
                        }
                        
                        if bonuses.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "star.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(TISColors.secondaryText.opacity(0.5))
                                
                                Text("No bonuses added")
                                    .font(.subheadline)
                                    .foregroundColor(TISColors.secondaryText)
                                
                                Text("Tap + to add bonus opportunities")
                                    .font(.caption)
                                    .foregroundColor(TISColors.secondaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(bonuses.indices, id: \.self) { index in
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Bonus Name")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(TISColors.secondaryText)
                                            
                                            TextField("e.g., Overtime, Holiday", text: $bonuses[index].name)
                                                .textFieldStyle(CustomTextFieldStyle())
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Amount")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(TISColors.secondaryText)
                                            
                                            HStack {
                                                Text("$")
                                                    .font(.subheadline)
                                                    .foregroundColor(TISColors.primary)
                                                
                                                TextField("0.00", text: $bonuses[index].amount)
                                                    .keyboardType(.decimalPad)
                                                    .textFieldStyle(CustomTextFieldStyle())
                                            }
                                        }
                                        .frame(width: 100)
                                        
                                        Button(action: {
                                            bonuses.remove(at: index)
                                        }) {
                                            Image(systemName: "trash.circle.fill")
                                                .font(.title3)
                                                .foregroundColor(TISColors.error)
                                        }
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(TISColors.cardBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(TISColors.cardBorder.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(TISColors.cardGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(TISColors.cardBorder.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .tisShadow(TISShadows.medium)
                    
                    // Preview Card
                    if !jobName.isEmpty && !hourlyRate.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(TISColors.success)
                                    .font(.title3)
                                
                                Text("Preview")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(TISColors.primaryText)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Job:")
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Text(jobName)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(TISColors.primary)
                                }
                                
                                HStack {
                                    Text("Rate:")
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Text(String(format: "$%.2f/hour", Double(hourlyRate) ?? 0))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(TISColors.success)
                                }
                                
                                if !bonuses.isEmpty {
                                    HStack {
                                        Text("Bonuses:")
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        Text("\(bonuses.count) added")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(TISColors.warning)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(TISColors.success.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(TISColors.success.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .tisShadow(TISShadows.medium)
                    }
                    
                    // Bottom padding
                    Color.clear
                        .frame(height: 100)
                }
                .padding(.horizontal, 20)
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
                    .opacity((jobName.isEmpty || hourlyRate.isEmpty) ? 0.6 : 1.0)
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .toast(isShowing: $showingToast, message: toastMessage, type: toastType)
    }
    
    private func saveJob() {
        // Validation
        guard !jobName.isEmpty else {
            toastMessage = "Please enter a job name"
            toastType = .warning
            showingToast = true
            return
        }
        
        guard !hourlyRate.isEmpty else {
            toastMessage = "Please enter an hourly rate"
            toastType = .warning
            showingToast = true
            return
        }
        
        guard let rate = Double(hourlyRate), rate > 0 else {
            toastMessage = "Please enter a valid hourly rate"
            toastType = .warning
            showingToast = true
            return
        }
        
        let job = Job(context: viewContext)
        job.id = UUID()
        job.name = jobName
        job.hourlyRate = rate
        job.createdAt = Date()
        
        // Add bonuses
        for bonusInput in bonuses {
            if !bonusInput.name.isEmpty && !bonusInput.amount.isEmpty {
                if let amount = Double(bonusInput.amount), amount > 0 {
                    let bonus = Bonus(context: viewContext)
                    bonus.id = UUID()
                    bonus.name = bonusInput.name
                    bonus.amount = amount
                    bonus.job = job
                }
            }
        }
        
        do {
            try viewContext.save()
            toastMessage = "Job '\(jobName)' added successfully!"
            toastType = .success
            showingToast = true
            
            // Dismiss after showing success toast
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            errorMessage = "Failed to save job: \(error.localizedDescription)"
            showingError = true
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(TISColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(TISColors.cardBorder.opacity(0.5), lineWidth: 1)
                    )
            )
    }
}

struct BonusInput {
    var name: String = ""
    var amount: String = ""
}

#Preview {
    AddJobView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
