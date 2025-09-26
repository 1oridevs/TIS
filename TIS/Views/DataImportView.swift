import SwiftUI
import CoreData

struct DataImportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var selectedImportType: ImportType = .csv
    @State private var showingFilePicker = false
    @State private var isImporting = false
    @State private var importResult: ImportResult?
    @State private var showingResult = false
    @State private var selectedFileURL: URL?
    
    enum ImportType: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
        case toggl = "Toggl"
        
        var description: String {
            switch self {
            case .csv:
                return "Import from CSV file with jobs and shifts"
            case .json:
                return "Import from JSON backup file"
            case .toggl:
                return "Import from Toggl time tracking export"
            }
        }
        
        var icon: String {
            switch self {
            case .csv:
                return "tablecells"
            case .json:
                return "doc.text"
            case .toggl:
                return "clock.arrow.circlepath"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 40))
                        .foregroundColor(TISColors.primary)
                    
                    Text("Import Data")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Text("Import your existing time tracking data from other apps")
                        .font(.subheadline)
                        .foregroundColor(TISColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Import Type Selection
                VStack(spacing: 16) {
                    Text("Select Import Type")
                        .font(.headline)
                        .foregroundColor(TISColors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(ImportType.allCases, id: \.self) { type in
                        ImportTypeCard(
                            type: type,
                            isSelected: selectedImportType == type,
                            onTap: { selectedImportType = type }
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Import Button
                VStack(spacing: 12) {
                    Button(action: startImport) {
                        HStack {
                            if isImporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "square.and.arrow.down")
                            }
                            Text(isImporting ? "Importing..." : "Select File to Import")
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
                    .disabled(isImporting)
                    .opacity(isImporting ? 0.6 : 1.0)
                    
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
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.commaSeparatedText, .json, .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedFileURL = url
                    performImport()
                }
            case .failure(let error):
                print("File picker error: \(error)")
            }
        }
        .alert("Import Result", isPresented: $showingResult) {
            Button("OK") { }
        } message: {
            if let result = importResult {
                Text("""
                Imported \(result.importedJobs) jobs and \(result.importedShifts) shifts.
                \(result.errors.isEmpty ? "No errors." : "\(result.errors.count) errors occurred.")
                """)
            }
        }
    }
    
    private func startImport() {
        showingFilePicker = true
    }
    
    private func performImport() {
        guard let fileURL = selectedFileURL else { return }
        
        isImporting = true
        
        Task {
            do {
                let data = try Data(contentsOf: fileURL)
                let result: ImportResult
                
                switch selectedImportType {
                case .csv:
                    result = try await DataImportManager.shared.importFromCSV(data, context: viewContext)
                case .json:
                    result = try await DataImportManager.shared.importFromJSON(data, context: viewContext)
                case .toggl:
                    result = try await DataImportManager.shared.importFromToggl(data, context: viewContext)
                }
                
                await MainActor.run {
                    importResult = result
                    showingResult = true
                    isImporting = false
                }
            } catch {
                await MainActor.run {
                    importResult = ImportResult(importedJobs: 0, importedShifts: 0, errors: [error.localizedDescription])
                    showingResult = true
                    isImporting = false
                }
            }
        }
    }
}

struct ImportTypeCard: View {
    let type: DataImportView.ImportType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : TISColors.primary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? TISColors.primary : TISColors.primary.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : TISColors.primaryText)
                    
                    Text(type.description)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : TISColors.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? TISColors.primary : TISColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? TISColors.primary : TISColors.cardBorder.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DataImportView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
