import Foundation
import CoreData

@objc(Shift)
public class Shift: NSManagedObject {
    
    // MARK: - Core Data Properties
    @NSManaged public var id: UUID?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var isActive: Bool
    @NSManaged public var shiftType: String?
    @NSManaged public var notes: String?
    @NSManaged public var bonusAmount: Double
    @NSManaged public var job: Job?
    @NSManaged public var bonuses: NSSet?
    
    // MARK: - Computed Properties
    
    var duration: TimeInterval {
        guard let startTime = startTime else { return 0 }
        let endTime = self.endTime ?? Date()
        return endTime.timeIntervalSince(startTime)
    }
    
    var durationInHours: Double {
        return duration / 3600
    }
    
    var baseEarnings: Double {
        guard let job = job else { return 0 }
        return durationInHours * job.hourlyRate
    }
    
    var totalEarnings: Double {
        let bonusTotal = bonuses?.allObjects.compactMap { $0 as? Bonus }.reduce(0) { $0 + $1.amount } ?? 0
        return baseEarnings + bonusTotal
    }
    
    var isCompleted: Bool {
        return endTime != nil && !isActive
    }
    
    // MARK: - Helper Methods
    
    func start() {
        startTime = Date()
        isActive = true
    }
    
    func end() {
        endTime = Date()
        isActive = false
    }
    
    func addBonus(_ bonus: Bonus) {
        let mutableBonuses = self.mutableSetValue(forKey: "bonuses")
        mutableBonuses.add(bonus)
    }
    
    func removeBonus(_ bonus: Bonus) {
        let mutableBonuses = self.mutableSetValue(forKey: "bonuses")
        mutableBonuses.remove(bonus)
    }
}
