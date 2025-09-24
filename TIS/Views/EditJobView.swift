import SwiftUI
import CoreData

struct EditJobView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    let job: Job
    
    @State private var jobName: String
    @State private var hourlyRate: String
    @State private var bonuses: [BonusInput]
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .info
    @State private var isAnimating = false
    
    init(job: Job) {
        self.job = job
        self._jobName = State(initialValue: job.name ?? "")
        self._hourlyRate = State(initialValue: String(job.hourlyRate))
        
        // Initialize bonuses from existing job
        let existingBonuses = job.bonuses?.allObjects as? [Bonus] ?? []
        self._bonuses = State(initialValue: existingBonuses.map { bonus in
            BonusInput(name: bonus.name ?? "", amount: String(bonus.amount))
        })
    }
    
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
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
                            
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text(localizationManager.localizedString(for: "jobs.edit_job"))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Text(localizationManager.localizedString(for: "jobs.edit_job_subtitle"))
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Job Information Card
                    TISCard {
                        VStack(alignment: .leading, spacing: 20) {
                            Text(localizationManager.localizedString(for: "jobs.job_information"))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                            
                            VStack(spacing: 16) {
                                // Job Name
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(localizationManager.localizedString(for: "jobs.job_name"))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(TISColors.primaryText)
                                    
                                    TextField(localizationManager.localizedString(for: "jobs.job_name_placeholder"), text: $jobName)
                                        .textFieldStyle(TISTextFieldStyle())
                                        .onChange(of: jobName) { oldValue, newValue in
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                isAnimating = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                isAnimating = false
                                            }
                                        }
                                }
                                
                                // Hourly Rate
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(localizationManager.localizedString(for: "jobs.hourly_rate"))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(TISColors.primaryText)
                                    
                                    HStack {
                                        Text(localizationManager.currentCurrency.symbol)
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(TISColors.primary)
                                        
                                        TextField("0.00", text: $hourlyRate)
                                            .textFieldStyle(TISTextFieldStyle())
                                            .keyboardType(.decimalPad)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Bonuses Section
                    TISCard {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text(localizationManager.localizedString(for: "jobs.bonuses"))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(TISColors.primaryText)
                                
                                Spacer()
                                
                                Button(action: addBonus) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(TISColors.primary)
                                }
                            }
                            
                            if bonuses.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "gift")
                                        .font(.title2)
                                        .foregroundColor(TISColors.secondaryText)
                                    
                                    Text(localizationManager.localizedString(for: "jobs.no_bonuses_added"))
                                        .font(.subheadline)
                                        .foregroundColor(TISColors.secondaryText)
                                    
                                    Text(localizationManager.localizedString(for: "jobs.add_bonuses_tip"))
                                        .font(.caption)
                                        .foregroundColor(TISColors.secondaryText)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(bonuses.indices, id: \.self) { index in
                                        BonusInputRow(
                                            bonus: $bonuses[index],
                                            onDelete: { removeBonus(at: index) }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        TISButton(localizationManager.localizedString(for: "jobs.save_changes"), icon: "checkmark.circle.fill", color: TISColors.success) {
                            saveJob()
                        }
                        .disabled(jobName.isEmpty || hourlyRate.isEmpty)
                        
                        TISSecondaryButton(localizationManager.localizedString(for: "jobs.cancel"), icon: "xmark.circle") {
                            dismiss()
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
            .background(TISColors.background)
            .navigationTitle(localizationManager.localizedString(for: "jobs.edit_job"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizationManager.localizedString(for: "jobs.cancel")) {
                        dismiss()
                    }
                }
            }
        }
        .toast(
            isShowing: $showingToast,
            message: toastMessage,
            type: toastType
        )
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        }
    }
    
    private func addBonus() {
        let _ = withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            bonuses.append(BonusInput(name: "", amount: ""))
        }
    }
    
    private func removeBonus(at index: Int) {
        let _ = withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            bonuses.remove(at: index)
        }
    }
    
    private func saveJob() {
        // Validation
        guard !jobName.isEmpty else {
            toastMessage = localizationManager.localizedString(for: "jobs.please_enter_job_name")
            toastType = .warning
            showingToast = true
            return
        }
        
        guard !hourlyRate.isEmpty else {
            toastMessage = localizationManager.localizedString(for: "jobs.please_enter_hourly_rate")
            toastType = .warning
            showingToast = true
            return
        }
        
        guard let rate = Double(hourlyRate), rate > 0 else {
            toastMessage = localizationManager.localizedString(for: "jobs.please_enter_valid_hourly_rate")
            toastType = .warning
            showingToast = true
            return
        }
        
        // Update job
        job.name = jobName
        job.hourlyRate = rate
        
        // Remove existing bonuses
        if let existingBonuses = job.bonuses?.allObjects as? [Bonus] {
            for bonus in existingBonuses {
                viewContext.delete(bonus)
            }
        }
        
        // Add new bonuses
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
            toastMessage = String(format: localizationManager.localizedString(for: "jobs.job_updated_success"), jobName)
            toastType = .success
            showingToast = true
            
            // Dismiss after showing success toast
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            errorMessage = String(format: localizationManager.localizedString(for: "jobs.failed_to_update_job"), error.localizedDescription)
            showingError = true
        }
    }
}

struct BonusInputRow: View {
    @Binding var bonus: BonusInput
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                TextField("Bonus name", text: $bonus.name)
                    .textFieldStyle(TISTextFieldStyle())
                
                HStack {
                    Text("$")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(TISColors.primary)
                    
                    TextField("0.00", text: $bonus.amount)
                        .textFieldStyle(TISTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .font(.title3)
                    .foregroundColor(TISColors.error)
            }
        }
        .padding(.vertical, 8)
    }
}

struct TISTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(TISColors.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(TISColors.border, lineWidth: 1)
            )
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let job = Job(context: context)
    job.name = "Sample Job"
    job.hourlyRate = 25.0
    
    return EditJobView(job: job)
        .environment(\.managedObjectContext, context)
}
