import SwiftUI

public enum ToastType {
    case success
    case error
    case warning
    case info
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return TISColors.success
        case .error: return TISColors.error
        case .warning: return TISColors.warning
        case .info: return TISColors.primary
        }
    }
}
