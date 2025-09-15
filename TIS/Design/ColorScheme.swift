import SwiftUI

struct TISColors {
    // Primary Colors
    static let primary = Color(red: 0.0, green: 0.48, blue: 1.0) // Blue
    static let primaryDark = Color(red: 0.0, green: 0.35, blue: 0.8)
    static let primaryLight = Color(red: 0.2, green: 0.6, blue: 1.0)
    
    // Accent Colors
    static let success = Color(red: 0.2, green: 0.78, blue: 0.35) // Green
    static let warning = Color(red: 1.0, green: 0.58, blue: 0.0) // Orange
    static let error = Color(red: 1.0, green: 0.23, blue: 0.19) // Red
    static let info = Color(red: 0.0, green: 0.48, blue: 1.0) // Blue
    
    // Shift Type Colors
    static let regular = Color(red: 0.0, green: 0.48, blue: 1.0) // Blue
    static let overtime = Color(red: 1.0, green: 0.58, blue: 0.0) // Orange
    static let specialEvent = Color(red: 0.69, green: 0.32, blue: 0.87) // Purple
    
    // Background Colors
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    
    // Text Colors
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let tertiaryText = Color(.tertiaryLabel)
    
    // Card Colors
    static let cardBackground = Color(.systemGray6)
    static let cardBorder = Color(.systemGray4)
    
    // Gradient Colors
    static let primaryGradient = LinearGradient(
        colors: [primary, primaryLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [success, Color.green],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warningGradient = LinearGradient(
        colors: [warning, Color.orange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct TISShadows {
    static let small = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    static let medium = Shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    static let large = Shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    func tisShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func tisCardStyle() -> some View {
        self
            .background(TISColors.cardBackground)
            .cornerRadius(12)
            .tisShadow(TISShadows.small)
    }
    
    func tisButtonStyle(color: Color = TISColors.primary) -> some View {
        self
            .foregroundColor(.white)
            .padding()
            .background(color)
            .cornerRadius(12)
            .tisShadow(TISShadows.small)
    }
}
