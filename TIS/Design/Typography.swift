import SwiftUI

struct TISTypography {
    // MARK: - Font Sizes
    static let largeTitle: CGFloat = 34
    static let title: CGFloat = 28
    static let title2: CGFloat = 22
    static let title3: CGFloat = 20
    static let headline: CGFloat = 17
    static let body: CGFloat = 17
    static let callout: CGFloat = 16
    static let subheadline: CGFloat = 15
    static let footnote: CGFloat = 13
    static let caption: CGFloat = 12
    static let caption2: CGFloat = 11
    
    // MARK: - Font Weights
    static let ultraLight = Font.Weight.ultraLight
    static let thin = Font.Weight.thin
    static let light = Font.Weight.light
    static let regular = Font.Weight.regular
    static let medium = Font.Weight.medium
    static let semibold = Font.Weight.semibold
    static let bold = Font.Weight.bold
    static let heavy = Font.Weight.heavy
    static let black = Font.Weight.black
    
    // MARK: - Design System
    static let display = Font.system(size: 48, weight: .bold, design: .rounded)
    static let h1 = Font.system(size: 32, weight: .bold, design: .rounded)
    static let h2 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let h3 = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let h4 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let h5 = Font.system(size: 18, weight: .medium, design: .rounded)
    static let h6 = Font.system(size: 16, weight: .medium, design: .rounded)
    
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    static let bodyRegular = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
    
    static let buttonLarge = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let buttonMedium = Font.system(size: 14, weight: .semibold, design: .rounded)
    static let buttonSmall = Font.system(size: 12, weight: .semibold, design: .rounded)
    
    static let captionLarge = Font.system(size: 12, weight: .regular, design: .default)
    static let captionMedium = Font.system(size: 11, weight: .regular, design: .default)
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .default)
}

// MARK: - Text Style Extensions
extension Text {
    func displayStyle() -> some View {
        self.font(TISTypography.display)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.primary, Color.primary.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    func h1Style() -> some View {
        self.font(TISTypography.h1)
            .foregroundColor(.primary)
    }
    
    func h2Style() -> some View {
        self.font(TISTypography.h2)
            .foregroundColor(.primary)
    }
    
    func h3Style() -> some View {
        self.font(TISTypography.h3)
            .foregroundColor(.primary)
    }
    
    func h4Style() -> some View {
        self.font(TISTypography.h4)
            .foregroundColor(.primary)
    }
    
    func h5Style() -> some View {
        self.font(TISTypography.h5)
            .foregroundColor(.primary)
    }
    
    func h6Style() -> some View {
        self.font(TISTypography.h6)
            .foregroundColor(.primary)
    }
    
    func bodyLargeStyle() -> some View {
        self.font(TISTypography.bodyLarge)
            .foregroundColor(.primary)
    }
    
    func bodyRegularStyle() -> some View {
        self.font(TISTypography.bodyRegular)
            .foregroundColor(.primary)
    }
    
    func bodySmallStyle() -> some View {
        self.font(TISTypography.bodySmall)
            .foregroundColor(.primary)
    }
    
    func labelLargeStyle() -> some View {
        self.font(TISTypography.labelLarge)
            .foregroundColor(.secondary)
    }
    
    func labelMediumStyle() -> some View {
        self.font(TISTypography.labelMedium)
            .foregroundColor(.secondary)
    }
    
    func labelSmallStyle() -> some View {
        self.font(TISTypography.labelSmall)
            .foregroundColor(.secondary)
    }
    
    func buttonLargeStyle() -> some View {
        self.font(TISTypography.buttonLarge)
            .foregroundColor(.white)
    }
    
    func buttonMediumStyle() -> some View {
        self.font(TISTypography.buttonMedium)
            .foregroundColor(.white)
    }
    
    func buttonSmallStyle() -> some View {
        self.font(TISTypography.buttonSmall)
            .foregroundColor(.white)
    }
    
    func captionLargeStyle() -> some View {
        self.font(TISTypography.captionLarge)
            .foregroundColor(.secondary)
    }
    
    func captionMediumStyle() -> some View {
        self.font(TISTypography.captionMedium)
            .foregroundColor(.secondary)
    }
    
    func captionSmallStyle() -> some View {
        self.font(TISTypography.captionSmall)
            .foregroundColor(.secondary)
    }
}

// MARK: - Gradient Text Styles
extension Text {
    func gradientStyle(colors: [Color]) -> some View {
        self.foregroundStyle(
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    func primaryGradientStyle() -> some View {
        self.gradientStyle(colors: [Color.blue, Color.purple])
    }
    
    func successGradientStyle() -> some View {
        self.gradientStyle(colors: [Color.green, Color.cyan])
    }
    
    func warningGradientStyle() -> some View {
        self.gradientStyle(colors: [Color.orange, Color.yellow])
    }
    
    func errorGradientStyle() -> some View {
        self.gradientStyle(colors: [Color.red, Color.pink])
    }
}
