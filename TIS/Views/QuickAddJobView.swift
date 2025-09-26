import SwiftUI
import CoreData

struct QuickAddJobView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var jobName = ""
    @State private var hourlyRate = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 40))
                        .foregroundColor(TISColors.primary)
                    
                    Text("Quick Add Job")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(TISColors.primaryText)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Form
                VStack(spacing: 20) {
                    // Job Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Job Name")
                            .font(.headline)
                            .foregroundColor(TISColors.primaryText)
                        
                        TextField("Enter job name", text: $jobName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    
                    // Hourly Rate
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hourly Rate")
                            .font(.headline)
                            .foregroundColor(TISColors.primaryText)
                        
                        HStack {
                            Text(localizationManager.currentCurrency.rawValue)
                                .font(.body)
                                .foregroundColor(TISColors.secondaryText)
                            
                            TextField("0.00", text: $hourlyRate)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: createJob) {
                        HStack {
                            if isCreating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "plus.circle.fill")
                            }
                            Text(isCreating ? "Creating..." : "Create Job")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
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
                    .disabled(jobName.isEmpty || hourlyRate.isEmpty || isCreating)
                    .opacity((jobName.isEmpty || hourlyRate.isEmpty || isCreating) ? 0.6 : 1.0)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(TISColors.secondaryText)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func createJob() {
        guard !jobName.isEmpty else {
            errorMessage = "Please enter a job name"
            showingError = true
            return
        }
        
        guard let rate = Double(hourlyRate), rate > 0 else {
            errorMessage = "Please enter a valid hourly rate"
            showingError = true
            return
        }
        
        isCreating = true
        
        let newJob = Job(context: viewContext)
        newJob.id = UUID()
        newJob.name = jobName
        newJob.hourlyRate = rate
        newJob.createdAt = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to create job: \(error.localizedDescription)"
            showingError = true
            isCreating = false
        }
    }
}

#Preview {
    QuickAddJobView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
