import SwiftUI

struct TISSpacing {
    // MARK: - 8pt Grid System
    static let xs: CGFloat = 4    // 0.5x
    static let sm: CGFloat = 8    // 1x
    static let md: CGFloat = 16   // 2x
    static let lg: CGFloat = 24   // 3x
    static let xl: CGFloat = 32   // 4x
    static let xxl: CGFloat = 40  // 5x
    static let xxxl: CGFloat = 48 // 6x
    
    // MARK: - Semantic Spacing
    static let cardPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 24
    static let itemSpacing: CGFloat = 16
    static let textSpacing: CGFloat = 8
    static let buttonSpacing: CGFloat = 12
    
    // MARK: - Layout Spacing
    static let screenPadding: CGFloat = 20
    static let cardSpacing: CGFloat = 16
    static let listSpacing: CGFloat = 12
    static let formSpacing: CGFloat = 20
    static let buttonPadding: CGFloat = 16
}

// MARK: - Spacing Extensions
extension View {
    func paddingXS() -> some View {
        self.padding(TISSpacing.xs)
    }
    
    func paddingSM() -> some View {
        self.padding(TISSpacing.sm)
    }
    
    func paddingMD() -> some View {
        self.padding(TISSpacing.md)
    }
    
    func paddingLG() -> some View {
        self.padding(TISSpacing.lg)
    }
    
    func paddingXL() -> some View {
        self.padding(TISSpacing.xl)
    }
    
    func paddingXXL() -> some View {
        self.padding(TISSpacing.xxl)
    }
    
    func paddingXXXL() -> some View {
        self.padding(TISSpacing.xxxl)
    }
    
    // MARK: - Semantic Padding
    func paddingCard() -> some View {
        self.padding(TISSpacing.cardPadding)
    }
    
    func paddingScreen() -> some View {
        self.padding(TISSpacing.screenPadding)
    }
    
    func paddingButton() -> some View {
        self.padding(TISSpacing.buttonPadding)
    }
    
    // MARK: - Spacing Modifiers
    func spacingXS() -> some View {
        self.spacing(TISSpacing.xs)
    }
    
    func spacingSM() -> some View {
        self.spacing(TISSpacing.sm)
    }
    
    func spacingMD() -> some View {
        self.spacing(TISSpacing.md)
    }
    
    func spacingLG() -> some View {
        self.spacing(TISSpacing.lg)
    }
    
    func spacingXL() -> some View {
        self.spacing(TISSpacing.xl)
    }
    
    // MARK: - Semantic Spacing
    func spacingCard() -> some View {
        self.spacing(TISSpacing.cardSpacing)
    }
    
    func spacingSection() -> some View {
        self.spacing(TISSpacing.sectionSpacing)
    }
    
    func spacingItem() -> some View {
        self.spacing(TISSpacing.itemSpacing)
    }
    
    func spacingText() -> some View {
        self.spacing(TISSpacing.textSpacing)
    }
    
    func spacingButton() -> some View {
        self.spacing(TISSpacing.buttonSpacing)
    }
}

// MARK: - Layout Helpers
struct SpacingView: View {
    let size: CGFloat
    
    var body: some View {
        Color.clear
            .frame(height: size)
    }
}

struct HorizontalSpacing: View {
    let size: CGFloat
    
    var body: some View {
        Color.clear
            .frame(width: size)
    }
}

// MARK: - Predefined Spacing Views
extension SpacingView {
    static let xs = SpacingView(size: TISSpacing.xs)
    static let sm = SpacingView(size: TISSpacing.sm)
    static let md = SpacingView(size: TISSpacing.md)
    static let lg = SpacingView(size: TISSpacing.lg)
    static let xl = SpacingView(size: TISSpacing.xl)
    static let xxl = SpacingView(size: TISSpacing.xxl)
    static let xxxl = SpacingView(size: TISSpacing.xxxl)
}

extension HorizontalSpacing {
    static let xs = HorizontalSpacing(size: TISSpacing.xs)
    static let sm = HorizontalSpacing(size: TISSpacing.sm)
    static let md = HorizontalSpacing(size: TISSpacing.md)
    static let lg = HorizontalSpacing(size: TISSpacing.lg)
    static let xl = HorizontalSpacing(size: TISSpacing.xl)
    static let xxl = HorizontalSpacing(size: TISSpacing.xxl)
    static let xxxl = HorizontalSpacing(size: TISSpacing.xxxl)
}
