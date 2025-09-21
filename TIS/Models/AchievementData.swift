import Foundation

// MARK: - Achievement Data Model
struct AchievementData: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let rarity: AchievementRarity
    let points: Int
    let targetValue: Double
    var currentValue: Double
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    init(id: UUID = UUID(), name: String, description: String, icon: String, category: AchievementCategory, rarity: AchievementRarity, points: Int, targetValue: Double, currentValue: Double = 0, isUnlocked: Bool = false, unlockedDate: Date? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.category = category
        self.rarity = rarity
        self.points = points
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
    
    var progressPercentage: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }
    
    var isCompleted: Bool {
        return currentValue >= targetValue
    }
}

enum AchievementCategory: String, CaseIterable, Codable {
    case timeTracking = "time_tracking"
    case earnings = "earnings"
    case consistency = "consistency"
    case milestones = "milestones"
    case special = "special"
    
    var displayName: String {
        switch self {
        case .timeTracking:
            return "Time Tracking"
        case .earnings:
            return "Earnings"
        case .consistency:
            return "Consistency"
        case .milestones:
            return "Milestones"
        case .special:
            return "Special"
        }
    }
}

enum AchievementRarity: String, CaseIterable, Codable {
    case common = "common"
    case uncommon = "uncommon"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"
    
    var displayName: String {
        switch self {
        case .common:
            return "Common"
        case .uncommon:
            return "Uncommon"
        case .rare:
            return "Rare"
        case .epic:
            return "Epic"
        case .legendary:
            return "Legendary"
        }
    }
    
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
extension AchievementData {
    static let predefinedAchievements: [AchievementData] = [
        // First Steps
        AchievementData(
            name: "First Shift",
            description: "Complete your first shift",
            icon: "play.circle.fill",
            category: .timeTracking,
            rarity: .common,
            points: 10,
            targetValue: 1
        ),
        AchievementData(
            name: "Getting Started",
            description: "Add your first job",
            icon: "briefcase.fill",
            category: .timeTracking,
            rarity: .common,
            points: 5,
            targetValue: 1
        ),
        
        // Time Tracking
        AchievementData(
            name: "Time Tracker",
            description: "Track 10 hours total",
            icon: "clock.fill",
            category: .timeTracking,
            rarity: .uncommon,
            points: 15,
            targetValue: 10
        ),
        AchievementData(
            name: "Marathon Worker",
            description: "Track 100 hours total",
            icon: "clock.badge.checkmark",
            category: .timeTracking,
            rarity: .rare,
            points: 50,
            targetValue: 100
        ),
        AchievementData(
            name: "Time Master",
            description: "Track 1000 hours total",
            icon: "clock.badge.exclamationmark",
            category: .timeTracking,
            rarity: .epic,
            points: 100,
            targetValue: 1000
        ),
        
        // Earnings
        AchievementData(
            name: "First Dollar",
            description: "Earn your first dollar",
            icon: "dollarsign.circle.fill",
            category: .earnings,
            rarity: .common,
            points: 10,
            targetValue: 1
        ),
        AchievementData(
            name: "Hundredaire",
            description: "Earn $100 total",
            icon: "dollarsign.square.fill",
            category: .earnings,
            rarity: .uncommon,
            points: 25,
            targetValue: 100
        ),
        AchievementData(
            name: "Thousandaire",
            description: "Earn $1,000 total",
            icon: "dollarsign.circle",
            category: .earnings,
            rarity: .rare,
            points: 75,
            targetValue: 1000
        ),
        AchievementData(
            name: "Money Maker",
            description: "Earn $10,000 total",
            icon: "banknote.fill",
            category: .earnings,
            rarity: .epic,
            points: 150,
            targetValue: 10000
        ),
        
        // Consistency
        AchievementData(
            name: "Daily Grind",
            description: "Work 7 days in a row",
            icon: "calendar.badge.clock",
            category: .consistency,
            rarity: .uncommon,
            points: 30,
            targetValue: 7
        ),
        AchievementData(
            name: "Week Warrior",
            description: "Work 4 weeks in a row",
            icon: "calendar.badge.checkmark",
            category: .consistency,
            rarity: .rare,
            points: 75,
            targetValue: 4
        ),
        AchievementData(
            name: "Monthly Master",
            description: "Work 3 months in a row",
            icon: "calendar.badge.exclamationmark",
            category: .consistency,
            rarity: .epic,
            points: 150,
            targetValue: 3
        ),
        
        // Special Achievements
        AchievementData(
            name: "Overtime Hero",
            description: "Work 10 overtime shifts",
            icon: "clock.badge.plus",
            category: .special,
            rarity: .rare,
            points: 40,
            targetValue: 10
        ),
        AchievementData(
            name: "Bonus Hunter",
            description: "Earn $500 in bonuses",
            icon: "gift.fill",
            category: .special,
            rarity: .rare,
            points: 60,
            targetValue: 500
        ),
        AchievementData(
            name: "Multi-Tasker",
            description: "Work 5 different jobs",
            icon: "person.3.fill",
            category: .special,
            rarity: .uncommon,
            points: 50,
            targetValue: 5
        ),
        
        // Milestones
        AchievementData(
            name: "Century Club",
            description: "Complete 100 shifts",
            icon: "100.circle.fill",
            category: .milestones,
            rarity: .epic,
            points: 100,
            targetValue: 100
        ),
        AchievementData(
            name: "Half Thousand",
            description: "Complete 500 shifts",
            icon: "500.circle.fill",
            category: .milestones,
            rarity: .legendary,
            points: 250,
            targetValue: 500
        ),
        AchievementData(
            name: "Thousand Club",
            description: "Complete 1000 shifts",
            icon: "1000.circle.fill",
            category: .milestones,
            rarity: .legendary,
            points: 500,
            targetValue: 1000
        )
    ]
}
