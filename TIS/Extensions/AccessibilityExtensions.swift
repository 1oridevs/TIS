import SwiftUI

// MARK: - Accessibility Extensions

extension View {
    /// Adds comprehensive accessibility support for buttons
    func accessibleButton(
        label: String,
        hint: String? = nil,
        action: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(named: action) {
                // This will be handled by the button's action
            }
    }
    
    /// Adds accessibility support for static text elements
    func accessibleText(
        label: String,
        value: String? = nil,
        hint: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityValue(value)
            .accessibilityHint(hint)
            .accessibilityAddTraits(.isStaticText)
    }
    
    /// Adds accessibility support for form elements
    func accessibleFormField(
        label: String,
        value: String? = nil,
        hint: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityValue(value)
            .accessibilityHint(hint)
            .accessibilityAddTraits(.isKeyboardKey)
    }
    
    /// Adds accessibility support for progress indicators
    func accessibleProgress(
        label: String,
        value: String,
        hint: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityValue(value)
            .accessibilityHint(hint)
            .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Dynamic Type Support

extension Font {
    /// Creates a font that supports Dynamic Type
    static func dynamicTitle() -> Font {
        .system(.title, design: .rounded, weight: .bold)
    }
    
    static func dynamicTitle2() -> Font {
        .system(.title2, design: .rounded, weight: .semibold)
    }
    
    static func dynamicHeadline() -> Font {
        .system(.headline, design: .rounded, weight: .semibold)
    }
    
    static func dynamicBody() -> Font {
        .system(.body, design: .rounded, weight: .regular)
    }
    
    static func dynamicSubheadline() -> Font {
        .system(.subheadline, design: .rounded, weight: .medium)
    }
    
    static func dynamicCaption() -> Font {
        .system(.caption, design: .rounded, weight: .medium)
    }
    
    static func dynamicCaption2() -> Font {
        .system(.caption2, design: .rounded, weight: .regular)
    }
}

// MARK: - Accessibility Constants

struct AccessibilityLabels {
    // Navigation
    static let dashboard = "Dashboard"
    static let timeTracking = "Time Tracking"
    static let jobs = "Jobs"
    static let history = "History"
    static let settings = "Settings"
    
    // Actions
    static let startShift = "Start shift"
    static let endShift = "End shift"
    static let addJob = "Add job"
    static let editJob = "Edit job"
    static let deleteJob = "Delete job"
    static let addShift = "Add shift"
    static let editShift = "Edit shift"
    static let deleteShift = "Delete shift"
    
    // Form Fields
    static let jobName = "Job name"
    static let hourlyRate = "Hourly rate"
    static let shiftStartTime = "Shift start time"
    static let shiftEndTime = "Shift end time"
    static let shiftNotes = "Shift notes"
    static let bonusAmount = "Bonus amount"
    static let bonusName = "Bonus name"
    
    // Statistics
    static let totalEarnings = "Total earnings"
    static let totalHours = "Total hours"
    static let shiftsCount = "Number of shifts"
    static let averageRate = "Average hourly rate"
    
    // Status
    static let currentlyTracking = "Currently tracking time"
    static let notTracking = "Not currently tracking"
    static let shiftInProgress = "Shift in progress"
    static let shiftCompleted = "Shift completed"
}

struct AccessibilityHints {
    // Actions
    static let startShift = "Begin tracking time for the selected job"
    static let endShift = "Stop tracking and save the current shift"
    static let addJob = "Create a new job with hourly rate and details"
    static let editJob = "Modify job details including name and hourly rate"
    static let deleteJob = "Permanently remove this job and all associated shifts"
    
    // Form Fields
    static let jobName = "Enter the name of your job or position"
    static let hourlyRate = "Enter your hourly wage or salary rate"
    static let shiftStartTime = "Select when your shift began"
    static let shiftEndTime = "Select when your shift ended"
    static let shiftNotes = "Add any additional notes about this shift"
    static let bonusAmount = "Enter the bonus amount earned"
    static let bonusName = "Enter a name or description for this bonus"
    
    // Navigation
    static let dashboard = "View your current status and recent activity"
    static let timeTracking = "Start or stop tracking your work time"
    static let jobs = "Manage your jobs and hourly rates"
    static let history = "View your work history and past shifts"
    static let settings = "Configure app settings and preferences"
}
