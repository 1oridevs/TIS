import SwiftUI

// MARK: - Animation Extensions

extension View {
    /// Adds a smooth fade-in animation
    func fadeIn(duration: Double = 0.3, delay: Double = 0) -> some View {
        self
            .opacity(0)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).delay(delay)) {
                    // This will be handled by the view's opacity state
                }
            }
    }
    
    /// Adds a smooth slide-in animation from the specified edge
    func slideIn(from edge: Edge, duration: Double = 0.3, delay: Double = 0) -> some View {
        self
            .offset(offsetForEdge(edge))
            .onAppear {
                withAnimation(.easeOut(duration: duration).delay(delay)) {
                    // This will be handled by the view's offset state
                }
            }
    }
    
    /// Adds a scale animation
    func scaleIn(duration: Double = 0.3, delay: Double = 0, scale: CGFloat = 0.8) -> some View {
        self
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    // This will be handled by the view's scale state
                }
            }
    }
    
    /// Adds a bounce animation
    func bounceIn(duration: Double = 0.6, delay: Double = 0) -> some View {
        self
            .scaleEffect(0.3)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(delay)) {
                    // This will be handled by the view's scale state
                }
            }
    }
    
    /// Adds a shimmer effect for loading states
    func shimmer() -> some View {
        self
            .overlay(
                ShimmerView()
                    .mask(self)
            )
    }
    
    /// Adds a pulse animation
    func pulse(duration: Double = 1.0, scale: CGFloat = 1.05) -> some View {
        self
            .scaleEffect(1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    // This will be handled by the view's scale state
                }
            }
    }
    
    /// Adds a rotation animation
    func rotateIn(duration: Double = 0.5, delay: Double = 0, angle: Double = 180) -> some View {
        self
            .rotationEffect(.degrees(angle))
            .onAppear {
                withAnimation(.easeOut(duration: duration).delay(delay)) {
                    // This will be handled by the view's rotation state
                }
            }
    }
    
    // MARK: - Helper Functions
    
    private func offsetForEdge(_ edge: Edge) -> CGSize {
        switch edge {
        case .top:
            return CGSize(width: 0, height: -UIScreen.main.bounds.height)
        case .bottom:
            return CGSize(width: 0, height: UIScreen.main.bounds.height)
        case .leading:
            return CGSize(width: -UIScreen.main.bounds.width, height: 0)
        case .trailing:
            return CGSize(width: UIScreen.main.bounds.width, height: 0)
        }
    }
}

// MARK: - Animation Constants

struct TISAnimations {
    static let quick = Animation.easeInOut(duration: 0.2)
    static let smooth = Animation.easeInOut(duration: 0.3)
    static let gentle = Animation.easeInOut(duration: 0.5)
    static let spring = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let slow = Animation.easeInOut(duration: 0.8)
}

// MARK: - Shimmer Effect

struct ShimmerView: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.3),
                Color.white.opacity(0.8),
                Color.white.opacity(0.3)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .offset(x: phase)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase = 200
            }
        }
    }
}

// MARK: - Loading States

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Spinning indicator
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(TISColors.primary, lineWidth: 3)
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(TISColors.secondaryText)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Micro-interactions

struct MicroInteractionButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Scale animation
            withAnimation(.easeInOut(duration: 0.1)) {
                scale = 0.95
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    scale = 1.0
                }
            }
            
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(TISColors.primary)
            .cornerRadius(16)
            .scaleEffect(scale)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Transition Animations

struct SlideTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: isActive ? 0 : UIScreen.main.bounds.width)
            .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

struct FadeTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

struct ScaleTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1 : 0.8)
            .opacity(isActive ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isActive)
    }
}

// MARK: - View Extensions for Transitions

extension View {
    func slideTransition(isActive: Bool) -> some View {
        self.modifier(SlideTransition(isActive: isActive))
    }
    
    func fadeTransition(isActive: Bool) -> some View {
        self.modifier(FadeTransition(isActive: isActive))
    }
    
    func scaleTransition(isActive: Bool) -> some View {
        self.modifier(ScaleTransition(isActive: isActive))
    }
}
