import SwiftUI

struct TISShadows {
    // MARK: - Elevation Levels
    static let none = Shadow(
        color: .clear,
        radius: 0,
        x: 0,
        y: 0
    )
    
    static let xs = Shadow(
        color: .black.opacity(0.05),
        radius: 2,
        x: 0,
        y: 1
    )
    
    static let sm = Shadow(
        color: .black.opacity(0.1),
        radius: 4,
        x: 0,
        y: 2
    )
    
    static let md = Shadow(
        color: .black.opacity(0.15),
        radius: 8,
        x: 0,
        y: 4
    )
    
    static let lg = Shadow(
        color: .black.opacity(0.2),
        radius: 12,
        x: 0,
        y: 6
    )
    
    static let xl = Shadow(
        color: .black.opacity(0.25),
        radius: 16,
        x: 0,
        y: 8
    )
    
    static let xxl = Shadow(
        color: .black.opacity(0.3),
        radius: 20,
        x: 0,
        y: 10
    )
    
    // MARK: - Semantic Shadows
    static let card = Shadow(
        color: .black.opacity(0.1),
        radius: 8,
        x: 0,
        y: 4
    )
    
    static let button = Shadow(
        color: .black.opacity(0.15),
        radius: 6,
        x: 0,
        y: 3
    )
    
    static let modal = Shadow(
        color: .black.opacity(0.3),
        radius: 24,
        x: 0,
        y: 12
    )
    
    static let floating = Shadow(
        color: .black.opacity(0.2),
        radius: 16,
        x: 0,
        y: 8
    )
    
    // MARK: - Colored Shadows
    static let primary = Shadow(
        color: Color.blue.opacity(0.3),
        radius: 12,
        x: 0,
        y: 6
    )
    
    static let success = Shadow(
        color: Color.green.opacity(0.3),
        radius: 12,
        x: 0,
        y: 6
    )
    
    static let warning = Shadow(
        color: Color.orange.opacity(0.3),
        radius: 12,
        x: 0,
        y: 6
    )
    
    static let error = Shadow(
        color: Color.red.opacity(0.3),
        radius: 12,
        x: 0,
        y: 6
    )
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Shadow Extensions
extension View {
    func shadow(_ shadow: Shadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
    
    func shadowXS() -> some View {
        self.shadow(TISShadows.xs)
    }
    
    func shadowSM() -> some View {
        self.shadow(TISShadows.sm)
    }
    
    func shadowMD() -> some View {
        self.shadow(TISShadows.md)
    }
    
    func shadowLG() -> some View {
        self.shadow(TISShadows.lg)
    }
    
    func shadowXL() -> some View {
        self.shadow(TISShadows.xl)
    }
    
    func shadowXXL() -> some View {
        self.shadow(TISShadows.xxl)
    }
    
    // MARK: - Semantic Shadows
    func shadowCard() -> some View {
        self.shadow(TISShadows.card)
    }
    
    func shadowButton() -> some View {
        self.shadow(TISShadows.button)
    }
    
    func shadowModal() -> some View {
        self.shadow(TISShadows.modal)
    }
    
    func shadowFloating() -> some View {
        self.shadow(TISShadows.floating)
    }
    
    // MARK: - Colored Shadows
    func shadowPrimary() -> some View {
        self.shadow(TISShadows.primary)
    }
    
    func shadowSuccess() -> some View {
        self.shadow(TISShadows.success)
    }
    
    func shadowWarning() -> some View {
        self.shadow(TISShadows.warning)
    }
    
    func shadowError() -> some View {
        self.shadow(TISShadows.error)
    }
    
    // MARK: - Multiple Shadows
    func multiShadow(_ shadows: [Shadow]) -> some View {
        var view = self
        for shadow in shadows {
            view = view.shadow(shadow)
        }
        return view
    }
    
    func layeredShadow() -> some View {
        self.multiShadow([
            TISShadows.sm,
            Shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        ])
    }
    
    func glowShadow(color: Color, intensity: CGFloat = 0.3) -> some View {
        self.shadow(
            Shadow(
                color: color.opacity(intensity),
                radius: 20,
                x: 0,
                y: 0
            )
        )
    }
}

// MARK: - Animated Shadows
struct AnimatedShadow: ViewModifier {
    @State private var shadowRadius: CGFloat = 8
    @State private var shadowOpacity: Double = 0.15
    
    let baseShadow: Shadow
    let animationDuration: Double
    
    init(baseShadow: Shadow, animationDuration: Double = 2.0) {
        self.baseShadow = baseShadow
        self.animationDuration = animationDuration
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(
                Shadow(
                    color: baseShadow.color.opacity(shadowOpacity),
                    radius: shadowRadius,
                    x: baseShadow.x,
                    y: baseShadow.y
                )
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: animationDuration)
                    .repeatForever(autoreverses: true)
                ) {
                    shadowRadius = baseShadow.radius * 1.5
                    shadowOpacity = baseShadow.color.opacity * 1.5
                }
            }
    }
}

extension View {
    func animatedShadow(_ shadow: Shadow, duration: Double = 2.0) -> some View {
        self.modifier(AnimatedShadow(baseShadow: shadow, animationDuration: duration))
    }
}
