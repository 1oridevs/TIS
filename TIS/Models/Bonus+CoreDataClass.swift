import Foundation
import CoreData

@objc(Bonus)
public class Bonus: NSManagedObject {
    
    // MARK: - Computed Properties
    
    var isUsed: Bool {
        return shifts?.count ?? 0 > 0
    }
    
    // MARK: - Helper Methods
    
    func canBeUsed() -> Bool {
        return !isUsed
    }
}
