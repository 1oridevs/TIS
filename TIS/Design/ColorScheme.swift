import SwiftUI

struct TISColors {
    // Primary Colors - Modern Blue
    static let primary = Color(red: 0.0, green: 0.48, blue: 1.0) // Blue
    static let primaryDark = Color(red: 0.0, green: 0.35, blue: 0.8)
    static let primaryLight = Color(red: 0.2, green: 0.6, blue: 1.0)
    
    // Accent Colors - Vibrant and Modern
    static let accent = Color(red: 0.0, green: 0.48, blue: 1.0) // Blue accent
    static let success = Color(red: 0.0, green: 0.8, blue: 0.4) // Bright Green
    static let warning = Color(red: 1.0, green: 0.6, blue: 0.0) // Bright Orange
    static let error = Color(red: 1.0, green: 0.3, blue: 0.3) // Bright Red
    static let info = Color(red: 0.0, green: 0.7, blue: 1.0) // Bright Blue
    
    // Shift Type Colors - Distinct and Modern
    static let regular = Color(red: 0.0, green: 0.6, blue: 1.0) // Bright Blue
    static let overtime = Color(red: 1.0, green: 0.6, blue: 0.0) // Bright Orange
    static let specialEvent = Color(red: 0.8, green: 0.2, blue: 0.8) // Bright Purple
    static let flexible = Color(red: 0.0, green: 0.8, blue: 0.4) // Bright Green
    
    // New Modern Colors
    static let gold = Color(red: 1.0, green: 0.8, blue: 0.0) // Gold
    static let purple = Color(red: 0.6, green: 0.2, blue: 0.8) // Purple
    static let teal = Color(red: 0.0, green: 0.8, blue: 0.8) // Teal
    static let pink = Color(red: 1.0, green: 0.4, blue: 0.8) // Pink
    
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
    static let border = Color(.systemGray4)
    
    // Gradient Colors - Modern and Vibrant
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
    
    static let goldGradient = LinearGradient(
        colors: [gold, Color.yellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let purpleGradient = LinearGradient(
        colors: [purple, specialEvent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let tealGradient = LinearGradient(
        colors: [teal, Color.cyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let pinkGradient = LinearGradient(
        colors: [pink, Color.pink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Card Gradients
    static let cardGradient = LinearGradient(
        colors: [cardBackground, Color(.systemGray5)],
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
            .background(TISColors.cardGradient)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(TISColors.cardBorder.opacity(0.3), lineWidth: 1)
            )
            .tisShadow(TISShadows.medium)
    }
    
    func tisButtonStyle(color: Color = TISColors.primary) -> some View {
        self
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(16)
            .tisShadow(TISShadows.small)
    }
    
    func tisGradientButtonStyle(gradient: LinearGradient = TISColors.primaryGradient) -> some View {
        self
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(gradient)
            .cornerRadius(16)
            .tisShadow(TISShadows.medium)
    }
    
    func tisGlassEffect() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    func tisPulseAnimation() -> some View {
        self
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: UUID())
    }
}
