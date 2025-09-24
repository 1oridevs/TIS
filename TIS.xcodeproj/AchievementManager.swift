import Foundation
import CoreData
import Combine

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var totalPoints: Int = 0
    @Published var unlockedAchievements: [Achievement] = []
    
    private init() {}
    
    /// Initializes achievement state by attempting to load unlocked achievements
    /// from Core Data and summing their points.
    func initializeAchievements(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        let request: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        request.predicate = NSPredicate(format: "isUnlocked == YES")
        
        do {
            let results = try context.fetch(request)
            unlockedAchievements = results
            totalPoints = results.reduce(0) { partial, achievement in
                partial + Int(achievement.points)
            }
        } catch {
            // If fetching fails, keep defaults
            unlockedAchievements = []
            totalPoints = 0
        }
    }
}
