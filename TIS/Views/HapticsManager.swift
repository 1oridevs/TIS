import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Centralizes haptic feedback usage across the app.
/// All methods are safe no-ops on platforms where UIKit isn't available.
final class HapticsManager {
    static let shared = HapticsManager()
    private init() {}

    // MARK: - Impact
    func tapLight() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    func tapMedium() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }

    func tapHeavy() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        #endif
    }

    // MARK: - Notifications
    func notifySuccess() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    func notifyWarning() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }

    func notifyError() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        #endif
    }
}
