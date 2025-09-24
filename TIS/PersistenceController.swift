import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for previews
        let sampleJob = Job(context: viewContext)
        sampleJob.id = UUID()
        sampleJob.name = "Sample Job"
        sampleJob.hourlyRate = 25.0
        sampleJob.createdAt = Date()
        
        let sampleShift = Shift(context: viewContext)
        sampleShift.id = UUID()
        sampleShift.job = sampleJob
        sampleShift.startTime = Date().addingTimeInterval(-3600) // 1 hour ago
        sampleShift.endTime = Date()
        sampleShift.isActive = false
        sampleShift.shiftType = "Regular"
        sampleShift.notes = "Sample shift"
        sampleShift.bonusAmount = 0.0
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TISModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
