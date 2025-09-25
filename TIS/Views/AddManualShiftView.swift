import SwiftUI
import CoreData

struct AddManualShiftView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var selectedJob: Job?
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(8 * 3600) // 8 hours later
    @State private var notes = ""
    @State private var bonusAmount = 0.0
    @State private var showingJobPicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .info
    
    let jobs: FetchedResults<Job>
    
    private var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    private var durationHours: Double {
        duration / 3600
    }
    
    private var isValidShift: Bool {
        selectedJob != nil && startDate < endDate && durationHours > 0
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(TISColors.primaryGradient)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        
                        Text(localizationManager.localizedString(for: "shifts.add_manual_shift"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(TISColors.primaryText)
                        
                        Text(localizationManager.localizedString(for: "shifts.record_past_work"))
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                    }
                    .padding(.top, 20)
                    
                    // Job Selection Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "briefcase.fill")
                                .foregroundColor(TISColors.primary)
                                .font(.title3)
                            
                            Text(localizationManager.localizedString(for: "shifts.job_selection"))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Spacer()
                        }
                        
                        Button(action: {
                            showingJobPicker = true
                        }) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(selectedJob == nil ? TISColors.secondaryText.opacity(0.2) : TISColors.primary.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: selectedJob == nil ? "plus" : "checkmark")
                                        .foregroundColor(selectedJob == nil ? TISColors.secondaryText : TISColors.primary)
                                        .font(.title3)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(selectedJob?.name ?? localizationManager.localizedString(for: "shifts.select_job"))
                                        .font(.headline)
                                        .foregroundColor(selectedJob == nil ? TISColors.secondaryText : TISColors.primaryText)
                                    
                                    if let job = selectedJob {
                                        Text("\(localizationManager.formatCurrency(job.hourlyRate))/hour")
                                            .font(.subheadline)
                                            .foregroundColor(TISColors.success)
                                    } else {
                                        Text(localizationManager.localizedString(for: "shifts.choose_work_position"))
                                            .font(.subheadline)
                                            .foregroundColor(TISColors.secondaryText)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(TISColors.secondaryText)
                                    .font(.caption)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(TISColors.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedJob == nil ? TISColors.cardBorder.opacity(0.5) : TISColors.primary.opacity(0.3), lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
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
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    // Time Selection Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(TISColors.primary)
                                .font(.title3)
                            
                            Text(localizationManager.localizedString(for: "shifts.time_details"))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(localizationManager.localizedString(for: "shifts.start_time"))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(TISColors.primaryText)
                                
                                DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(localizationManager.localizedString(for: "shifts.end_time"))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(TISColors.primaryText)
                                
                                DatePicker("", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                            }
                            
                            // Duration Display
                            HStack {
                                Image(systemName: "timer")
                                    .foregroundColor(TISColors.success)
                                
                                Text(localizationManager.localizedString(for: "shifts.duration"))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text(String(format: "%.1f hours", durationHours))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(TISColors.success)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(TISColors.success.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(TISColors.success.opacity(0.3), lineWidth: 1)
                                    )
                            )
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
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    // Additional Details Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(TISColors.primary)
                                .font(.title3)
                            
                            Text(localizationManager.localizedString(for: "shifts.additional_details"))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(localizationManager.localizedString(for: "shifts.notes_optional"))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(TISColors.primaryText)
                                
                                TextField(localizationManager.localizedString(for: "shifts.add_notes_placeholder"), text: $notes, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(3...6)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(localizationManager.localizedString(for: "shifts.bonus_amount"))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(TISColors.primaryText)
                                
                                HStack {
                                    Text(localizationManager.currentCurrency.symbol)
                                        .font(.title3)
                                        .foregroundColor(TISColors.primary)
                                    
                                    TextField("0.00", value: $bonusAmount, format: .currency(code: localizationManager.currentCurrency.rawValue))
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    // Earnings Preview Card
                    if let job = selectedJob {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(TISColors.success)
                                    .font(.title3)
                                
                                Text(localizationManager.localizedString(for: "shifts.earnings_preview"))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(TISColors.primaryText)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("\(localizationManager.localizedString(for: "shifts.base_pay")) (\(String(format: "%.1f", durationHours)) hours)")
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Text(localizationManager.formatCurrency(durationHours * job.hourlyRate))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                
                                if bonusAmount > 0 {
                                    HStack {
                                        Text(localizationManager.localizedString(for: "shifts.bonus"))
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        Text(localizationManager.formatCurrency(bonusAmount))
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(TISColors.success)
                                    }
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text(localizationManager.localizedString(for: "shifts.total_earnings"))
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Text(localizationManager.formatCurrency((durationHours * job.hourlyRate) + bonusAmount))
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(TISColors.success)
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
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    
                    // Bottom padding
                    Color.clear
                        .frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle(localizationManager.localizedString(for: "shifts.add_manual_shift"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizationManager.localizedString(for: "jobs.cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizationManager.localizedString(for: "shifts.save")) {
                        saveShift()
                    }
                    .disabled(!isValidShift)
                    .opacity(isValidShift ? 1.0 : 0.6)
                }
            }
        }
        .sheet(isPresented: $showingJobPicker) {
            JobPickerView(selectedJob: $selectedJob, jobs: jobs)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .toast(isShowing: $showingToast, message: toastMessage, type: toastType)
    }
    
    private func saveShift() {
        // Validation
        guard let job = selectedJob else {
            toastMessage = localizationManager.localizedString(for: "shifts.please_select_job")
            toastType = .warning
            showingToast = true
            return
        }
        
        guard startDate < endDate else {
            toastMessage = localizationManager.localizedString(for: "shifts.end_time_after_start")
            toastType = .warning
            showingToast = true
            return
        }
        
        guard durationHours > 0 else {
            toastMessage = localizationManager.localizedString(for: "shifts.duration_greater_than_zero")
            toastType = .warning
            showingToast = true
            return
        }
        
        let shift = Shift(context: viewContext)
        shift.id = UUID()
        shift.job = job
        shift.startTime = startDate
        shift.endTime = endDate
        shift.isActive = false
        shift.notes = notes.isEmpty ? nil : notes
        shift.bonusAmount = bonusAmount
        
        // Auto-detect shift type based on duration and time
        let hours = durationHours
        
        if hours > 8 {
            shift.shiftType = "Overtime"
        } else if hours >= 6 {
            shift.shiftType = "Regular"
        } else {
            shift.shiftType = "Flexible"
        }
        
        do {
            try viewContext.save()
            toastMessage = localizationManager.localizedString(for: "shifts.shift_added_success")
            toastType = .success
            showingToast = true
            
            // Dismiss after showing success toast
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            errorMessage = String(format: localizationManager.localizedString(for: "shifts.failed_to_save_shift"), error.localizedDescription)
            showingError = true
        }
    }
}

struct JobPickerView: View {
    @Binding var selectedJob: Job?
    let jobs: FetchedResults<Job>
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(jobs, id: \.id) { job in
                    Button(action: {
                        selectedJob = job
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(job.name ?? "Unknown Job")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("\(localizationManager.formatCurrency(job.hourlyRate))/hour")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedJob?.id == job.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(TISColors.primary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(localizationManager.localizedString(for: "shifts.select_job_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizationManager.localizedString(for: "shifts.done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // Create a mock preview using a simple view
    VStack {
        Text("Add Manual Shift Preview")
            .font(.title)
        Text("This view requires a FetchedResults<Job> parameter")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
    .environment(\.managedObjectContext, context)
}
