import SwiftUI
import CoreData

// MARK: - BonusInput

struct BonusInput: Identifiable {
    let id = UUID()
    var name: String
    var amount: String
}

struct AddJobView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var jobName = ""
    @State private var hourlyRate = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isCreating = false
    @State private var animateHeader = false
    @State private var animateForm = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
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
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Enhanced Header
                        VStack(spacing: 20) {
                            ZStack {
                                // Background circle with gradient
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [TISColors.primary.opacity(0.1), TISColors.primary.opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .scaleEffect(animateHeader ? 1.0 : 0.8)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateHeader)
                                
                                // Icon with animation
                                Image(systemName: "briefcase.fill")
                                    .font(.system(size: 50, weight: .medium))
                                    .foregroundColor(TISColors.primary)
                                    .scaleEffect(animateHeader ? 1.0 : 0.5)
                                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animateHeader)
                            }
                            
                            VStack(spacing: 12) {
                                Text("Create New Job")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(TISColors.primaryText)
                                    .opacity(animateHeader ? 1.0 : 0.0)
                                    .animation(.easeInOut(duration: 0.6).delay(0.3), value: animateHeader)
                                
                                Text("Add your job details to start tracking time and earnings")
                                    .font(.body)
                                    .foregroundColor(TISColors.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .opacity(animateHeader ? 1.0 : 0.0)
                                    .animation(.easeInOut(duration: 0.6).delay(0.4), value: animateHeader)
                            }
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 40)
                        
                        // Enhanced Form Card
                        VStack(spacing: 24) {
                            // Job Name Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(TISColors.primary)
                                    
                                    Text("Job Information")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(TISColors.primaryText)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Job Name")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(TISColors.primaryText)
                                    
                                    TextField("e.g., Software Developer", text: $jobName)
                                        .font(.body)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(TISColors.cardBackground)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(jobName.isEmpty ? TISColors.secondaryText.opacity(0.3) : TISColors.primary.opacity(0.5), lineWidth: 1)
                                                )
                                        )
                                        .animation(.easeInOut(duration: 0.2), value: jobName.isEmpty)
                                }
                            }
                            
                            // Hourly Rate Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "dollarsign.circle")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(TISColors.success)
                                    
                                    Text("Compensation")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(TISColors.primaryText)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Hourly Rate")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(TISColors.primaryText)
                                    
                                    HStack(spacing: 12) {
                                        // Currency Symbol
                                        HStack(spacing: 4) {
                                            Text(localizationManager.currentCurrency.symbol)
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(TISColors.primary)
                                            
                                            Text(localizationManager.currentCurrency.rawValue)
                                                .font(.caption)
                                                .foregroundColor(TISColors.secondaryText)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(TISColors.primary.opacity(0.1))
                                        )
                                        
                        TextField("0.00", text: $hourlyRate)
                            .keyboardType(.decimalPad)
                                            .font(.body)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(TISColors.cardBackground)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(hourlyRate.isEmpty ? TISColors.secondaryText.opacity(0.3) : TISColors.success.opacity(0.5), lineWidth: 1)
                                                    )
                                            )
                                            .animation(.easeInOut(duration: 0.2), value: hourlyRate.isEmpty)
                                    }
                                }
                            }
                            
                            // Quick Tips
                            VStack(alignment: .leading, spacing: 8) {
                        HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(TISColors.warning)
                                    
                                    Text("Quick Tips")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(TISColors.primaryText)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("• Use descriptive job names like 'Frontend Developer' or 'Freelance Writing'")
                                        .font(.caption)
                                        .foregroundColor(TISColors.secondaryText)
                                    
                                    Text("• Include your exact hourly rate for accurate earnings calculations")
                                        .font(.caption)
                                        .foregroundColor(TISColors.secondaryText)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(TISColors.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(TISColors.cardBorder.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 20)
                        .opacity(animateForm ? 1.0 : 0.0)
                        .offset(y: animateForm ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: animateForm)
                        
                        Spacer(minLength: 40)
                        
                        // Enhanced Action Buttons
                        VStack(spacing: 16) {
                            // Create Job Button
                            Button(action: createJob) {
                                HStack(spacing: 12) {
                                    if isCreating {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 18, weight: .medium))
                                    }
                                    
                                    Text(isCreating ? "Creating Job..." : "Create Job")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
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
                                .cornerRadius(16)
                                .shadow(color: TISColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(jobName.isEmpty || hourlyRate.isEmpty || isCreating)
                            .opacity((jobName.isEmpty || hourlyRate.isEmpty || isCreating) ? 0.6 : 1.0)
                            .scaleEffect((jobName.isEmpty || hourlyRate.isEmpty || isCreating) ? 0.98 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: jobName.isEmpty || hourlyRate.isEmpty || isCreating)
                            
                            // Cancel Button
                    Button("Cancel") {
                        dismiss()
                    }
                            .font(.headline)
                            .foregroundColor(TISColors.secondaryText)
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                        .opacity(animateForm ? 1.0 : 0.0)
                        .offset(y: animateForm ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: animateForm)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            animateHeader = true
            animateForm = true
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
    AddJobView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}