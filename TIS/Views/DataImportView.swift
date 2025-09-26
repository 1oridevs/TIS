import SwiftUI
import CoreData

struct DataImportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @StateObject private var importManager: DataImportManager
    @State private var selectedImportType: DataImportManager.ImportType = .csv
    @State private var showingFilePicker = false
    @State private var importResult: DataImportManager.ImportResult?
    @State private var showingResult = false
    @State private var selectedFileURL: URL?
    
    init() {
        self._importManager = StateObject(wrappedValue: DataImportManager(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 40))
                        .foregroundColor(TISColors.primary)
                    
                    Text(localizationManager.localizedString(for: "import.title"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Text(localizationManager.localizedString(for: "import.subtitle"))
                        .font(.subheadline)
                        .foregroundColor(TISColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Import Type Selection
                VStack(spacing: 16) {
                    Text(localizationManager.localizedString(for: "import.select_type"))
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
                
                // Progress Section
                if importManager.isImporting {
                    VStack(spacing: 12) {
                        Text(importManager.currentStatus)
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                            .multilineTextAlignment(.center)
                        
                        ProgressView(value: importManager.importProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: TISColors.primary))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(TISColors.primary.opacity(0.05))
                    )
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Import Button
                VStack(spacing: 12) {
                    Button(action: startImport) {
                        HStack {
                            if importManager.isImporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "square.and.arrow.down")
                            }
                            Text(importManager.isImporting ? "Importing..." : "Select File to Import")
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
                    .disabled(importManager.isImporting)
                    .opacity(importManager.isImporting ? 0.6 : 1.0)
                    
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
        
        Task {
            let result = await importManager.importData(from: fileURL, type: selectedImportType)
            
            await MainActor.run {
                importResult = result
                showingResult = true
            }
        }
    }
}

struct ImportTypeCard: View {
    let type: DataImportManager.ImportType
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
