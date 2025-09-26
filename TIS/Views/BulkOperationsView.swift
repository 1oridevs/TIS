import SwiftUI
import CoreData

struct BulkOperationsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var selectedShifts: Set<Shift> = []
    @State private var selectedJobs: Set<Job> = []
    @State private var showingDeleteConfirmation = false
    @State private var showingEditJobs = false
    @State private var operationType: OperationType = .shifts
    
    enum OperationType: String, CaseIterable {
        case shifts = "Shifts"
        case jobs = "Jobs"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Operation Type Picker
                Picker("Operation Type", selection: $operationType) {
                    ForEach(OperationType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                if operationType == .shifts {
                    BulkShiftsView(
                        selectedShifts: $selectedShifts,
                        onDelete: {
                            showingDeleteConfirmation = true
                        }
                    )
                } else {
                    BulkJobsView(
                        selectedJobs: $selectedJobs,
                        onDelete: {
                            showingDeleteConfirmation = true
                        },
                        onEdit: {
                            showingEditJobs = true
                        }
                    )
                }
            }
            .navigationTitle("Bulk Operations")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        clearSelection()
                    }
                    .disabled(selectedItems.isEmpty)
                }
            }
            .alert("Delete Selected Items", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteSelectedItems()
                }
            } message: {
                Text("Are you sure you want to delete \(selectedItems.count) selected \(operationType.rawValue.lowercased())? This action cannot be undone.")
            }
            .sheet(isPresented: $showingEditJobs) {
                BulkEditJobsView(
                    selectedJobs: Array(selectedJobs),
                    onSave: { updatedJobs in
                        saveJobChanges(updatedJobs)
                    }
                )
            }
        }
    }
    
    private var selectedItems: [Any] {
        if operationType == .shifts {
            return Array(selectedShifts)
        } else {
            return Array(selectedJobs)
        }
    }
    
    private func clearSelection() {
        selectedShifts.removeAll()
        selectedJobs.removeAll()
    }
    
    private func deleteSelectedItems() {
        if operationType == .shifts {
            deleteSelectedShifts()
        } else {
            deleteSelectedJobs()
        }
        clearSelection()
    }
    
    private func deleteSelectedShifts() {
        for shift in selectedShifts {
            viewContext.delete(shift)
        }
        try? viewContext.save()
    }
    
    private func deleteSelectedJobs() {
        for job in selectedJobs {
            viewContext.delete(job)
        }
        try? viewContext.save()
    }
    
    private func saveJobChanges(_ updatedJobs: [Job]) {
        try? viewContext.save()
        clearSelection()
    }
}

// MARK: - Bulk Shifts View

struct BulkShiftsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedShifts: Set<Shift>
    let onDelete: () -> Void
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Shift.startTime, ascending: false)],
        predicate: NSPredicate(format: "isActive == NO"),
        animation: .default)
    private var shifts: FetchedResults<Shift>
    
    var body: some View {
        VStack(spacing: 0) {
            // Selection Summary
            if !selectedShifts.isEmpty {
                HStack {
                    Text("\(selectedShifts.count) shifts selected")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("Delete Selected") {
                        onDelete()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .padding()
                .background(Color(.systemGray6))
            }
            
            // Shifts List
            List {
                ForEach(shifts, id: \.id) { shift in
                    ShiftSelectionRow(
                        shift: shift,
                        isSelected: selectedShifts.contains(shift),
                        onToggle: {
                            toggleShiftSelection(shift)
                        }
                    )
                }
            }
            .listStyle(PlainListStyle())
        }
    }
    
    private func toggleShiftSelection(_ shift: Shift) {
        if selectedShifts.contains(shift) {
            selectedShifts.remove(shift)
        } else {
            selectedShifts.insert(shift)
        }
    }
}

// MARK: - Bulk Jobs View

struct BulkJobsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedJobs: Set<Job>
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Job.name, ascending: true)],
        animation: .default)
    private var jobs: FetchedResults<Job>
    
    var body: some View {
        VStack(spacing: 0) {
            // Selection Summary
            if !selectedJobs.isEmpty {
                HStack {
                    Text("\(selectedJobs.count) jobs selected")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button("Edit") {
                            onEdit()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("Delete") {
                            onDelete()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
            
            // Jobs List
            List {
                ForEach(jobs, id: \.id) { job in
                    JobSelectionRow(
                        job: job,
                        isSelected: selectedJobs.contains(job),
                        onToggle: {
                            toggleJobSelection(job)
                        }
                    )
                }
            }
            .listStyle(PlainListStyle())
        }
    }
    
    private func toggleJobSelection(_ job: Job) {
        if selectedJobs.contains(job) {
            selectedJobs.remove(job)
        } else {
            selectedJobs.insert(job)
        }
    }
}

// MARK: - Selection Rows

struct ShiftSelectionRow: View {
    let shift: Shift
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(shift.job?.name ?? "Unknown Job")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(shift.shiftType ?? "Regular")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let startTime = shift.startTime {
                    Text(startTime.formatted(.dateTime.month().day().hour().minute()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let startTime = shift.startTime, let endTime = shift.endTime {
                let duration = endTime.timeIntervalSince(startTime) / 3600
                Text(String(format: "%.1fh", duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct JobSelectionRow: View {
    let job: Job
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(job.name ?? "Unknown Job")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("$\(String(format: "%.2f", job.hourlyRate))/hour")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(job.isActive ? "Active" : "Inactive")
                    .font(.caption)
                    .foregroundColor(job.isActive ? .green : .red)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Bulk Edit Jobs View

struct BulkEditJobsView: View {
    let selectedJobs: [Job]
    let onSave: ([Job]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var updatedJobs: [Job] = []
    @State private var hourlyRate: Double = 0.0
    @State private var isActive: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Edit \(selectedJobs.count) Jobs")
                        .font(.headline)
                }
                
                Section("Hourly Rate") {
                    HStack {
                        Text("Set hourly rate for all jobs:")
                        Spacer()
                        TextField("0.00", value: $hourlyRate, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                    }
                }
                
                Section("Status") {
                    Toggle("Mark all jobs as active", isOn: $isActive)
                }
                
                Section {
                    Button("Apply Changes") {
                        applyChanges()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Bulk Edit Jobs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadJobData()
        }
    }
    
    private func loadJobData() {
        updatedJobs = selectedJobs
        if let firstJob = selectedJobs.first {
            hourlyRate = firstJob.hourlyRate
            isActive = firstJob.isActive
        }
    }
    
    private func applyChanges() {
        for job in updatedJobs {
            job.hourlyRate = hourlyRate
            job.isActive = isActive
            job.updatedAt = Date()
        }
        onSave(updatedJobs)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    BulkOperationsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
