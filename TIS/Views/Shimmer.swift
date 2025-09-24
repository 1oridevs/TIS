import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.0
    let duration: Double
    let bounce: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy in
                    let gradient = LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.45),
                            Color.white.opacity(0.15)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Rectangle()
                        .fill(gradient)
                        .rotationEffect(.degrees(20))
                        .offset(x: proxy.size.width * phase, y: 0)
                        .frame(width: proxy.size.width * 1.5)
                        .blendMode(.plusLighter)
                }
                .clipped()
            )
            .onAppear {
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: bounce)
                ) {
                    phase = 1.5
                }
            }
    }
}

extension View {
    /// Applies a shimmering loading effect to any view.
    /// - Parameters:
    ///   - active: Whether the shimmer is active.
    ///   - duration: Duration of one shimmer pass.
    ///   - bounce: Whether the shimmer should reverse back.
    func shimmer(active: Bool = true, duration: Double = 1.2, bounce: Bool = false) -> some View {
        Group {
            if active {
                self.modifier(ShimmerModifier(duration: duration, bounce: bounce))
            } else {
                self
            }
        }
    }
}
