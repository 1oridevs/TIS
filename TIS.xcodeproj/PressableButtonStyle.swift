import SwiftUI

/// A button style that provides a subtle press-down effect
/// by scaling the content and reducing opacity while pressed.
public struct PressableButtonStyle: ButtonStyle {
    private let scale: CGFloat
    private let pressedOpacity: Double

    public init(scale: CGFloat = 0.97, pressedOpacity: Double = 0.85) {
        self.scale = scale
        self.pressedOpacity = pressedOpacity
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? pressedOpacity : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}
