import SwiftUI

struct AnimatedBackgroundView: View {
    var body: some View {
        // Simple gradient background without heavy animations to prevent freezing
        LinearGradient(
            colors: [
                TISColors.background,
                TISColors.background.opacity(0.95),
                TISColors.primary.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    AnimatedBackgroundView()
}