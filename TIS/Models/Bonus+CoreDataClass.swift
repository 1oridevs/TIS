import Foundation
import CoreData

@objc(Bonus)
public class Bonus: NSManagedObject {
    
    // MARK: - Core Data Properties
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var amount: Double
    @NSManaged public var job: Job?
    @NSManaged public var shifts: NSSet?
    
    // MARK: - Computed Properties
    
    var isUsed: Bool {
        return shifts?.count ?? 0 > 0
    }
    
    // MARK: - Helper Methods
    
    func canBeUsed() -> Bool {
        return !isUsed
    }
}
