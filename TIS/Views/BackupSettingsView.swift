import SwiftUI
import CoreData

struct BackupSettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var backupManager = DataBackupManager.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var showingBackupOptions = false
    @State private var showingRestoreOptions = false
    @State private var showingDeleteConfirmation = false
    @State private var selectedBackupURL: URL?
    @State private var showingShareSheet = false
    @State private var backupURL: URL?
    
    var body: some View {
        NavigationView {
            List {
                // Backup Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "icloud.and.arrow.up")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Create Backup")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Save all your data to a file")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if backupManager.isBackingUp {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Button("Backup") {
                                    createBackup()
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(backupManager.isBackingUp)
                            }
                        }
                        
                        if let lastBackup = backupManager.lastBackupDate {
                            Text("Last backup: \(lastBackup.formatted(.dateTime.month().day().hour().minute()))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if backupManager.isBackingUp {
                            ProgressView(value: backupManager.backupProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Data Backup")
                }
                
                // Restore Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "icloud.and.arrow.down")
                                .foregroundColor(.green)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Restore from Backup")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Load data from a backup file")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Restore") {
                                showingRestoreOptions = true
                            }
                            .buttonStyle(.bordered)
                            .disabled(backupManager.isRestoring || availableBackups.isEmpty)
                        }
                        
                        if backupManager.isRestoring {
                            ProgressView(value: backupManager.backupProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Data Restore")
                }
                
                // Available Backups
                if !availableBackups.isEmpty {
                    Section {
                        ForEach(availableBackups, id: \.self) { backupURL in
                            BackupRowView(
                                backupURL: backupURL,
                                onRestore: {
                                    restoreFromBackup(backupURL)
                                },
                                onShare: {
                                    shareBackup(backupURL)
                                },
                                onDelete: {
                                    deleteBackup(backupURL)
                                }
                            )
                        }
                    } header: {
                        Text("Available Backups")
                    }
                }
                
                // Info Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("Backup Information")
                                .font(.headline)
                        }
                        
                        Text("• Backups include all your jobs, shifts, bonuses, and achievements")
                        Text("• Backup files are stored locally on your device")
                        Text("• You can share backup files to transfer data between devices")
                        Text("• Restoring will replace all current data with backup data")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                } header: {
                    Text("About Backups")
                }
            }
            .navigationTitle("Data Backup")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingShareSheet) {
                if let backupURL = backupURL {
                    ShareSheet(activityItems: [backupURL])
                }
            }
            .alert("Delete Backup", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let url = selectedBackupURL {
                        deleteBackup(url)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this backup? This action cannot be undone.")
            }
        }
    }
    
    private var availableBackups: [URL] {
        backupManager.getAvailableBackups()
    }
    
    private func createBackup() {
        Task {
            do {
                let backupURL = try await backupManager.createBackup(context: viewContext)
                self.backupURL = backupURL
                showingShareSheet = true
            } catch {
                print("Backup failed: \(error)")
            }
        }
    }
    
    private func restoreFromBackup(_ url: URL) {
        Task {
            do {
                try await backupManager.restoreFromBackup(url: url, context: viewContext)
            } catch {
                print("Restore failed: \(error)")
            }
        }
    }
    
    private func shareBackup(_ url: URL) {
        backupURL = url
        showingShareSheet = true
    }
    
    private func deleteBackup(_ url: URL) {
        do {
            try backupManager.deleteBackup(url: url)
        } catch {
            print("Delete failed: \(error)")
        }
    }
}

// MARK: - Backup Row View

struct BackupRowView: View {
    let backupURL: URL
    let onRestore: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(backupURL.lastPathComponent)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let attributes = try? FileManager.default.attributesOfItem(atPath: backupURL.path),
                       let creationDate = attributes[.creationDate] as? Date {
                        Text("Created: \(creationDate.formatted(.dateTime.month().day().hour().minute()))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let attributes = try? FileManager.default.attributesOfItem(atPath: backupURL.path),
                       let fileSize = attributes[.size] as? Int {
                        Text("Size: \(ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button("Restore") {
                        onRestore()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button("Share") {
                        onShare()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button("Delete") {
                        showingDeleteConfirmation = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
        .alert("Delete Backup", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this backup? This action cannot be undone.")
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    BackupSettingsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
