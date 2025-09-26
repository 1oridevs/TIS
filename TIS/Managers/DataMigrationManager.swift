import Foundation
import CoreData

class DataMigrationManager: ObservableObject {
    @Published var isMigrating = false
    @Published var migrationProgress: Double = 0.0
    @Published var currentStatus = ""
    
    private let persistentContainer: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
    }
    
    // MARK: - Migration Status
    
    enum MigrationStatus {
        case notNeeded
        case required
        case inProgress
        case completed
        case failed(Error)
    }
    
    // MARK: - Check Migration Status
    
    func checkMigrationStatus() -> MigrationStatus {
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
            return .notNeeded
        }
        
        do {
            let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
            let currentModel = persistentContainer.managedObjectModel
            
            if !currentModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) {
                return .required
            }
            
            return .notNeeded
        } catch {
            return .failed(error)
        }
    }
    
    // MARK: - Perform Migration
    
    func performMigration() async -> MigrationStatus {
        await MainActor.run {
            isMigrating = true
            migrationProgress = 0.0
            currentStatus = "Checking migration requirements..."
        }
        
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
            await MainActor.run {
                isMigrating = false
            }
            return .notNeeded
        }
        
        do {
            await MainActor.run {
                currentStatus = "Preparing for migration..."
                migrationProgress = 0.1
            }
            
            // Get the current model
            let currentModel = persistentContainer.managedObjectModel
            
            // Get the source model
            let sourceModel = try getSourceModel(for: storeURL)
            
            await MainActor.run {
                currentStatus = "Creating migration mapping..."
                migrationProgress = 0.2
            }
            
            // Create migration mapping
            let mappingModel = try createMappingModel(from: sourceModel, to: currentModel)
            
            await MainActor.run {
                currentStatus = "Performing migration..."
                migrationProgress = 0.3
            }
            
            // Perform the migration
            try await performLightweightMigration(from: sourceModel, to: currentModel, at: storeURL)
            
            await MainActor.run {
                currentStatus = "Migration completed successfully!"
                migrationProgress = 1.0
                isMigrating = false
            }
            
            return .completed
            
        } catch {
            await MainActor.run {
                currentStatus = "Migration failed: \(error.localizedDescription)"
                isMigrating = false
            }
            return .failed(error)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getSourceModel(for storeURL: URL) throws -> NSManagedObjectModel {
        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
        
        // Try to find the source model
        if let sourceModel = NSManagedObjectModel.mergedModel(from: [Bundle.main], forStoreMetadata: metadata) {
            return sourceModel
        }
        
        // If no source model found, create a basic one
        return createBasicModel()
    }
    
    private func createBasicModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Add basic entities that might exist in older versions
        let jobEntity = NSEntityDescription()
        jobEntity.name = "Job"
        jobEntity.managedObjectClassName = "Job"
        
        let jobIdAttribute = NSAttributeDescription()
        jobIdAttribute.name = "id"
        jobIdAttribute.attributeType = .UUIDAttributeType
        jobIdAttribute.isOptional = false
        
        let jobNameAttribute = NSAttributeDescription()
        jobNameAttribute.name = "name"
        jobNameAttribute.attributeType = .stringAttributeType
        jobNameAttribute.isOptional = true
        
        jobEntity.properties = [jobIdAttribute, jobNameAttribute]
        model.entities = [jobEntity]
        
        return model
    }
    
    private func createMappingModel(from sourceModel: NSManagedObjectModel, to destinationModel: NSManagedObjectModel) throws -> NSMappingModel {
        // Try to find an existing mapping model
        if let mappingModel = NSMappingModel(from: [Bundle.main], forSourceModel: sourceModel, destinationModel: destinationModel) {
            return mappingModel
        }
        
        // Create a lightweight migration mapping
        return try NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
    }
    
    private func performLightweightMigration(from sourceModel: NSManagedObjectModel, to destinationModel: NSManagedObjectModel, at storeURL: URL) async throws {
        // Create a temporary coordinator for migration
        let migrationCoordinator = NSPersistentStoreCoordinator(managedObjectModel: sourceModel)
        
        // Add the source store
        let sourceStore = try migrationCoordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
        )
        
        // Create migration manager
        let migrationManager = NSMigrationManager(sourceModel: sourceModel, destinationModel: destinationModel)
        
        // Create destination store URL
        let destinationURL = storeURL.appendingPathExtension("migrated")
        
        // Perform migration
        try migrationManager.migrateStore(
            from: sourceStore.url!,
            sourceType: NSSQLiteStoreType,
            options: nil,
            with: NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel),
            toDestinationURL: destinationURL,
            destinationType: NSSQLiteStoreType,
            destinationOptions: nil
        )
        
        // Replace the original store with the migrated one
        try FileManager.default.removeItem(at: storeURL)
        try FileManager.default.moveItem(at: destinationURL, to: storeURL)
        
        // Update progress
        await MainActor.run {
            migrationProgress = 0.9
        }
    }
    
    // MARK: - Backup Before Migration
    
    func createBackupBeforeMigration() async throws -> URL {
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
            throw MigrationError.noStoreURL
        }
        
        let backupURL = storeURL.appendingPathExtension("backup")
        
        try FileManager.default.copyItem(at: storeURL, to: backupURL)
        
        return backupURL
    }
    
    // MARK: - Restore From Backup
    
    func restoreFromBackup(_ backupURL: URL) async throws {
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
            throw MigrationError.noStoreURL
        }
        
        // Remove current store
        if FileManager.default.fileExists(atPath: storeURL.path) {
            try FileManager.default.removeItem(at: storeURL)
        }
        
        // Restore from backup
        try FileManager.default.copyItem(at: backupURL, to: storeURL)
    }
}

// MARK: - Migration Errors

enum MigrationError: LocalizedError {
    case noStoreURL
    case migrationFailed(String)
    case backupFailed(String)
    case restoreFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .noStoreURL:
            return "No store URL found"
        case .migrationFailed(let message):
            return "Migration failed: \(message)"
        case .backupFailed(let message):
            return "Backup failed: \(message)"
        case .restoreFailed(let message):
            return "Restore failed: \(message)"
        }
    }
}