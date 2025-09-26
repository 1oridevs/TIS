import SwiftUI
import CoreData

struct EditShiftView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    let shift: Shift
    
    @State private var selectedJob: Job?
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var notes: String
    @State private var bonusAmount: Double
    @State private var shiftType: String
    @State private var showingJobPicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .info
    @State private var isSaving = false
    
    let jobs: FetchedResults<Job>
    
    init(shift: Shift, jobs: FetchedResults<Job>) {
        self.shift = shift
        self.jobs = jobs
        self._selectedJob = State(initialValue: shift.job)
        self._startDate = State(initialValue: shift.startTime ?? Date())
        self._endDate = State(initialValue: shift.endTime ?? Date())
        self._notes = State(initialValue: shift.notes ?? "")
        self._bonusAmount = State(initialValue: shift.bonusAmount)
        self._shiftType = State(initialValue: shift.shiftType ?? "Regular")
    }
    
    private var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    private var durationHours: Double {
        duration / 3600
    }
    
    private var isValidShift: Bool {
        selectedJob != nil && startDate < endDate && durationHours > 0
    }
    
    private var totalEarnings: Double {
        guard let job = selectedJob else { return 0 }
        let baseEarnings = durationHours * job.hourlyRate
        return baseEarnings + bonusAmount
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                TISColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [TISColors.primary.opacity(0.1), TISColors.primary.opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(TISColors.primary)
                            }
                            
                            VStack(spacing: 8) {
                                Text(localizationManager.localizedString(for: "shifts.edit_shift"))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(TISColors.primaryText)
                                
                                Text(localizationManager.localizedString(for: "shifts.edit_shift_subtitle"))
                                    .font(.body)
                                    .foregroundColor(TISColors.secondaryText)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Form
                        VStack(spacing: 20) {
                            // Job Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text(localizationManager.localizedString(for: "shifts.job"))
                                    .font(.headline)
                                    .foregroundColor(TISColors.primaryText)
                                
                                Button(action: {
                                    showingJobPicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "briefcase.fill")
                                            .foregroundColor(TISColors.primary)
                                        
                                        Text(selectedJob?.name ?? localizationManager.localizedString(for: "shifts.select_job"))
                                            .foregroundColor(selectedJob != nil ? TISColors.primaryText : TISColors.secondaryText)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(TISColors.secondaryText)
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(TISColors.cardBackground)
                                            .stroke(selectedJob != nil ? TISColors.primary : TISColors.border, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Date and Time Selection
                            VStack(spacing: 16) {
                                HStack(spacing: 16) {
                                    // Start Date/Time
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(localizationManager.localizedString(for: "shifts.start_time"))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(TISColors.primaryText)
                                        
                                        DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                                            .datePickerStyle(CompactDatePickerStyle())
                                            .labelsHidden()
                                    }
                                    
                                    // End Date/Time
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(localizationManager.localizedString(for: "shifts.end_time"))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(TISColors.primaryText)
                                        
                                        DatePicker("", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                                            .datePickerStyle(CompactDatePickerStyle())
                                            .labelsHidden()
                                    }
                                }
                                
                                // Duration Display
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(TISColors.primary)
                                    
                                    Text("\(String(format: "%.1f", durationHours)) \(localizationManager.localizedString(for: "shifts.hours"))")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(TISColors.primaryText)
                                    
                                    Spacer()
                                    
                                    if let job = selectedJob {
                                        Text(localizationManager.formatCurrency(totalEarnings))
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(TISColors.success)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(TISColors.primary.opacity(0.05))
                                )
                            }
                            
                            // Shift Type
                            VStack(alignment: .leading, spacing: 12) {
                                Text(localizationManager.localizedString(for: "shifts.shift_type"))
                                    .font(.headline)
                                    .foregroundColor(TISColors.primaryText)
                                
                                Picker("Shift Type", selection: $shiftType) {
                                    Text("Regular").tag("Regular")
                                    Text("Overtime").tag("Overtime")
                                    Text("Flexible").tag("Flexible")
                                    Text("Night").tag("Night")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            // Notes
                            VStack(alignment: .leading, spacing: 12) {
                                Text(localizationManager.localizedString(for: "shifts.notes"))
                                    .font(.headline)
                                    .foregroundColor(TISColors.primaryText)
                                
                                TextField(localizationManager.localizedString(for: "shifts.notes_placeholder"), text: $notes, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(3...6)
                            }
                            
                            // Bonus Amount
                            VStack(alignment: .leading, spacing: 12) {
                                Text(localizationManager.localizedString(for: "shifts.bonus"))
                                    .font(.headline)
                                    .foregroundColor(TISColors.primaryText)
                                
                                HStack {
                                    Text(localizationManager.currentCurrency.symbol)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(TISColors.primary)
                                    
                                    TextField("0.00", value: $bonusAmount, format: .currency(code: localizationManager.currentCurrency.rawValue))
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Save Button
                        TISButton(
                            title: isSaving ? localizationManager.localizedString(for: "common.saving") : localizationManager.localizedString(for: "common.save"),
                            icon: "checkmark.circle.fill"
                        ) {
                            saveShift()
                        }
                        .disabled(!isValidShift || isSaving)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(localizationManager.localizedString(for: "shifts.edit_shift"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizationManager.localizedString(for: "common.cancel")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingJobPicker) {
                JobPickerView(selectedJob: $selectedJob, jobs: jobs)
            }
            .overlay(
                ToastView(message: toastMessage, type: toastType, isShowing: $showingToast)
                    .animation(.easeInOut, value: showingToast)
            )
        }
    }
    
    private func saveShift() {
        isSaving = true
        
        // Validation
        guard let job = selectedJob else {
            toastMessage = localizationManager.localizedString(for: "shifts.please_select_job")
            toastType = .warning
            showingToast = true
            isSaving = false
            return
        }
        
        guard startDate < endDate else {
            toastMessage = localizationManager.localizedString(for: "shifts.end_time_after_start")
            toastType = .warning
            showingToast = true
            isSaving = false
            return
        }
        
        guard durationHours > 0 else {
            toastMessage = localizationManager.localizedString(for: "shifts.duration_greater_than_zero")
            toastType = .warning
            showingToast = true
            isSaving = false
            return
        }
        
        // Update shift
        shift.job = job
        shift.startTime = startDate
        shift.endTime = endDate
        shift.notes = notes.isEmpty ? nil : notes
        shift.bonusAmount = bonusAmount
        shift.shiftType = shiftType
        
        do {
            try viewContext.save()
            toastMessage = localizationManager.localizedString(for: "shifts.shift_updated_success")
            toastType = .success
            showingToast = true
            
            // Dismiss after showing success toast
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            errorMessage = String(format: localizationManager.localizedString(for: "shifts.failed_to_save_shift"), error.localizedDescription)
            showingError = true
            isSaving = false
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let job = Job(context: context)
    job.name = "Sample Job"
    job.hourlyRate = 25.0
    
    let shift = Shift(context: context)
    shift.job = job
    shift.startTime = Date()
    shift.endTime = Date().addingTimeInterval(8 * 3600)
    shift.notes = "Sample shift"
    shift.bonusAmount = 50.0
    shift.shiftType = "Regular"
    
    return EditShiftView(shift: shift, jobs: FetchRequest<Job>(entity: Job.entity(), sortDescriptors: []).wrappedValue)
        .environmentObject(LocalizationManager())
}
