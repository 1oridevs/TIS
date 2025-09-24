import Foundation
import UIKit

final class HapticsManager {
    static let shared = HapticsManager()
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let successNotification = UINotificationFeedbackGenerator()
    private let warningNotification = UINotificationFeedbackGenerator()
    private let errorNotification = UINotificationFeedbackGenerator()

    private init() {}

    func tapLight() {
        impactLight.prepare()
        impactLight.impactOccurred()
    }

    func tapMedium() {
        impactMedium.prepare()
        impactMedium.impactOccurred()
    }

    func tapHeavy() {
        impactHeavy.prepare()
        impactHeavy.impactOccurred()
    }

    func notifySuccess() {
        successNotification.notificationOccurred(.success)
    }

    func notifyWarning() {
        warningNotification.notificationOccurred(.warning)
    }

    func notifyError() {
        errorNotification.notificationOccurred(.error)
    }
}


