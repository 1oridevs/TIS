import Foundation
import CoreData

@objc(Achievement)
public class Achievement: NSManagedObject, Identifiable {
    
}

extension Achievement {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Achievement> {
        return NSFetchRequest<Achievement>(entityName: "Achievement")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var description: String
    @NSManaged public var iconName: String
    @NSManaged public var isUnlocked: Bool
    @NSManaged public var unlockedAt: Date?
    @NSManaged public var category: String
    @NSManaged public var points: Int32
    @NSManaged public var requirement: String
    @NSManaged public var progress: Double
    @NSManaged public var maxProgress: Double
}

extension Achievement {
    var progressPercentage: Double {
        guard maxProgress > 0 else { return 0 }
        return min(progress / maxProgress, 1.0)
    }
    
    var isCompleted: Bool {
        return progress >= maxProgress
    }
    
    var rarity: AchievementRarity {
        switch points {
        case 0...10:
            return .common
        case 11...25:
            return .uncommon
        case 26...50:
            return .rare
        case 51...100:
            return .epic
        default:
            return .legendary
        }
    }
}

enum AchievementRarity: String, CaseIterable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var color: String {
        switch self {
        case .common:
            return "gray"
        case .uncommon:
            return "green"
        case .rare:
            return "blue"
        case .epic:
            return "purple"
        case .legendary:
            return "gold"
        }
    }
    
    var icon: String {
        switch self {
        case .common:
            return "star.fill"
        case .uncommon:
            return "star.circle.fill"
        case .rare:
            return "star.square.fill"
        case .epic:
            return "crown.fill"
        case .legendary:
            return "crown.circle.fill"
        }
    }
}

// MARK: - Predefined Achievements

extension Achievement {
    static let predefinedAchievements: [AchievementData] = [
        // First Steps
        AchievementData(
            name: "First Shift",
            description: "Complete your first shift",
            iconName: "play.circle.fill",
            category: "First Steps",
            points: 10,
            requirement: "Complete 1 shift",
            maxProgress: 1
        ),
        AchievementData(
            name: "Getting Started",
            description: "Add your first job",
            iconName: "briefcase.fill",
            category: "First Steps",
            points: 5,
            requirement: "Add 1 job",
            maxProgress: 1
        ),
        
        // Time Tracking
        AchievementData(
            name: "Time Tracker",
            description: "Track 10 hours total",
            iconName: "clock.fill",
            category: "Time Tracking",
            points: 15,
            requirement: "Track 10 hours",
            maxProgress: 10
        ),
        AchievementData(
            name: "Marathon Worker",
            description: "Track 100 hours total",
            iconName: "clock.badge.checkmark",
            category: "Time Tracking",
            points: 50,
            requirement: "Track 100 hours",
            maxProgress: 100
        ),
        AchievementData(
            name: "Time Master",
            description: "Track 1000 hours total",
            iconName: "clock.badge.exclamationmark",
            category: "Time Tracking",
            points: 100,
            requirement: "Track 1000 hours",
            maxProgress: 1000
        ),
        
        // Earnings
        AchievementData(
            name: "First Dollar",
            description: "Earn your first dollar",
            iconName: "dollarsign.circle.fill",
            category: "Earnings",
            points: 10,
            requirement: "Earn $1",
            maxProgress: 1
        ),
        AchievementData(
            name: "Hundredaire",
            description: "Earn $100 total",
            iconName: "dollarsign.square.fill",
            category: "Earnings",
            points: 25,
            requirement: "Earn $100",
            maxProgress: 100
        ),
        AchievementData(
            name: "Thousandaire",
            description: "Earn $1,000 total",
            iconName: "dollarsign.circle",
            category: "Earnings",
            points: 75,
            requirement: "Earn $1,000",
            maxProgress: 1000
        ),
        AchievementData(
            name: "Money Maker",
            description: "Earn $10,000 total",
            iconName: "banknote.fill",
            category: "Earnings",
            points: 150,
            requirement: "Earn $10,000",
            maxProgress: 10000
        ),
        
        // Consistency
        AchievementData(
            name: "Daily Grind",
            description: "Work 7 days in a row",
            iconName: "calendar.badge.clock",
            category: "Consistency",
            points: 30,
            requirement: "Work 7 consecutive days",
            maxProgress: 7
        ),
        AchievementData(
            name: "Week Warrior",
            description: "Work 4 weeks in a row",
            iconName: "calendar.badge.checkmark",
            category: "Consistency",
            points: 75,
            requirement: "Work 4 consecutive weeks",
            maxProgress: 4
        ),
        AchievementData(
            name: "Monthly Master",
            description: "Work 3 months in a row",
            iconName: "calendar.badge.exclamationmark",
            category: "Consistency",
            points: 150,
            requirement: "Work 3 consecutive months",
            maxProgress: 3
        ),
        
        // Special Achievements
        AchievementData(
            name: "Overtime Hero",
            description: "Work 10 overtime shifts",
            iconName: "clock.badge.plus",
            category: "Special",
            points: 40,
            requirement: "Work 10 overtime shifts",
            maxProgress: 10
        ),
        AchievementData(
            name: "Bonus Hunter",
            description: "Earn $500 in bonuses",
            iconName: "gift.fill",
            category: "Special",
            points: 60,
            requirement: "Earn $500 in bonuses",
            maxProgress: 500
        ),
        AchievementData(
            name: "Multi-Tasker",
            description: "Work 5 different jobs",
            iconName: "person.3.fill",
            category: "Special",
            points: 50,
            requirement: "Work 5 different jobs",
            maxProgress: 5
        ),
        
        // Milestones
        AchievementData(
            name: "Century Club",
            description: "Complete 100 shifts",
            iconName: "100.circle.fill",
            category: "Milestones",
            points: 100,
            requirement: "Complete 100 shifts",
            maxProgress: 100
        ),
        AchievementData(
            name: "Half Thousand",
            description: "Complete 500 shifts",
            iconName: "500.circle.fill",
            category: "Milestones",
            points: 250,
            requirement: "Complete 500 shifts",
            maxProgress: 500
        ),
        AchievementData(
            name: "Thousand Club",
            description: "Complete 1000 shifts",
            iconName: "1000.circle.fill",
            category: "Milestones",
            points: 500,
            requirement: "Complete 1000 shifts",
            maxProgress: 1000
        )
    ]
}

struct AchievementData {
    let name: String
    let description: String
    let iconName: String
    let category: String
    let points: Int32
    let requirement: String
    let maxProgress: Double
}
