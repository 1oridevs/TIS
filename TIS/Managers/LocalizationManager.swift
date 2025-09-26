import SwiftUI
import Foundation

@MainActor
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language = .english
    @Published var currentCurrency: Currency = .usd
    
    private init() {
        // Load saved preferences
        loadPreferences()
    }
    
    // MARK: - Language Support
    
    enum Language: String, CaseIterable {
        case english = "en"
        case hebrew = "he"
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .hebrew: return "עברית"
            }
        }
        
        var isRTL: Bool {
            return self == .hebrew
        }
    }
    
    enum Currency: String, CaseIterable {
        case usd = "USD"
        case ils = "ILS"
        case eur = "EUR"
        case gbp = "GBP"
        
        var symbol: String {
            switch self {
            case .usd: return "$"
            case .ils: return "₪"
            case .eur: return "€"
            case .gbp: return "£"
            }
        }
        
        var displayName: String {
            switch self {
            case .usd: return "US Dollar"
            case .ils: return "Israeli Shekel"
            case .eur: return "Euro"
            case .gbp: return "British Pound"
            }
        }
    }
    
    // MARK: - Localized Strings
    
    func localizedString(for key: String) -> String {
        switch currentLanguage {
        case .english:
            return englishStrings[key] ?? key
        case .hebrew:
            return hebrewStrings[key] ?? englishStrings[key] ?? key
        }
    }
    
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currentCurrency.rawValue
        formatter.locale = Locale(identifier: currentLanguage.rawValue)
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currentCurrency.symbol)\(String(format: "%.2f", amount))"
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 3600)) / 60
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    // MARK: - Language Switching
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
        savePreferences()
        applyLayoutDirection()
        objectWillChange.send()
    }
    
    func setCurrency(_ currency: Currency) {
        currentCurrency = currency
        savePreferences()
        objectWillChange.send()
    }
    
    // MARK: - Persistence
    
    private func loadPreferences() {
        if let languageString = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: languageString) {
            currentLanguage = language
        }
        
        if let currencyString = UserDefaults.standard.string(forKey: "selectedCurrency"),
           let currency = Currency(rawValue: currencyString) {
            currentCurrency = currency
        }
    }
    
    private func savePreferences() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
        UserDefaults.standard.set(currentCurrency.rawValue, forKey: "selectedCurrency")
    }
    
    private func applyLayoutDirection() {
    #if canImport(UIKit)
        let isRTL = currentLanguage.isRTL
        let attribute: UISemanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        if Thread.isMainThread {
            UIView.appearance().semanticContentAttribute = attribute
            UINavigationBar.appearance().semanticContentAttribute = attribute
            UITabBar.appearance().semanticContentAttribute = attribute
        } else {
            DispatchQueue.main.async {
                UIView.appearance().semanticContentAttribute = attribute
                UINavigationBar.appearance().semanticContentAttribute = attribute
                UITabBar.appearance().semanticContentAttribute = attribute
            }
        }
    #endif
    }
    
    // MARK: - English Strings
    
    private let englishStrings: [String: String] = [
        // Navigation
        "nav.dashboard": "Dashboard",
        "nav.time_tracking": "Time Tracking",
        "nav.jobs": "Jobs",
        "nav.history": "History",
        "nav.analytics": "Analytics",
        "nav.settings": "Settings",
        
        // Dashboard
        "dashboard.title": "Dashboard",
        "dashboard.welcome": "Welcome to TIS",
        "dashboard.good_morning": "Good Morning",
        "dashboard.good_afternoon": "Good Afternoon",
        "dashboard.good_evening": "Good Evening",
        "dashboard.current_status": "Current Status",
        "dashboard.quick_actions": "Quick Actions",
        "dashboard.jobs_overview": "Jobs Overview",
        "dashboard.recent_activity": "Recent Activity",
        "dashboard.earnings_goals": "Earnings Goals",
        "dashboard.start_tracking": "Start Tracking",
        "dashboard.add_job": "Add Job",
        "dashboard.view_history": "View History",
        "dashboard.tracking": "TRACKING",
        "dashboard.ready": "READY",
        "dashboard.live": "LIVE",
        "dashboard.job": "Job:",
        "dashboard.duration": "Duration:",
        "dashboard.earnings": "Earnings:",
        "dashboard.no_jobs": "No jobs yet",
        "dashboard.add_first_job": "Add your first job to get started",
        "dashboard.no_recent_activity": "No recent activity",
        "dashboard.start_tracking_to_see_activity": "Start tracking to see your activity here",
        
        // Time Tracking
        "time_tracking.title": "Time Tracking",
        "time_tracking.start_shift": "Start Shift",
        "time_tracking.end_shift": "End Shift",
        "time_tracking.select_job": "Select Job",
        "time_tracking.shift_type": "Shift Type",
        "time_tracking.notes": "Notes",
        "time_tracking.tracking": "TRACKING",
        "time_tracking.ready": "READY",
        "time_tracking.regular": "Regular",
        "time_tracking.overtime": "Overtime",
        "time_tracking.special": "Special Event",
        "time_tracking.flexible": "Flexible",
        "time_tracking.no_jobs_available": "No jobs available",
        "time_tracking.add_job_first": "Add a job first to start tracking",
        "time_tracking.shift_notes_placeholder": "Add notes for this shift...",
        "time_tracking.character_count": "characters",
        
        // Jobs
        "jobs.title": "Jobs",
        "jobs.add_job": "Add Job",
        "jobs.edit_job": "Edit Job",
        "jobs.delete_job": "Delete Job",
        "jobs.job_name": "Job Name",
        "jobs.hourly_rate": "Hourly Rate",
        "jobs.bonuses": "Bonuses",
        "jobs.total_hours": "Total Hours",
        "jobs.total_earnings": "Total Earnings",
        "jobs.no_jobs": "No jobs yet",
        "jobs.add_first_job": "Add your first job to get started",
        "jobs.job_name_placeholder": "Enter job name",
        "jobs.hourly_rate_placeholder": "0.00",
        "jobs.bonus_name_placeholder": "Bonus name",
        "jobs.bonus_amount_placeholder": "0.00",
        "jobs.add_bonus": "Add Bonus",
        "jobs.remove_bonus": "Remove",
        "jobs.save_job": "Save Job",
        "jobs.cancel": "Cancel",
        "jobs.delete": "Delete",
        "jobs.edit": "Edit",
        "jobs.job_name_required": "Job name is required",
        "jobs.hourly_rate_required": "Hourly rate is required",
        "jobs.hourly_rate_invalid": "Please enter a valid hourly rate",
        "jobs.job_saved": "Job saved successfully",
        "jobs.job_deleted": "Job deleted successfully",
        "jobs.error_saving": "Error saving job",
        "jobs.error_deleting": "Error deleting job",
        "jobs.add_job_subtitle": "Create a new work position to track",
        "jobs.job_information": "Job Information",
        "jobs.bonuses_optional": "Bonuses (Optional)",
        "jobs.no_bonuses": "No bonuses added",
        "jobs.add_bonus_tip": "Tap + to add bonus opportunities",
        "jobs.preview": "Preview",
        "jobs.job_label": "Job:",
        "jobs.rate_label": "Rate:",
        "jobs.bonuses_label": "Bonuses:",
        "jobs.bonus_name": "Bonus Name",
        "jobs.amount": "Amount",
        "jobs.shifts_count": "Shifts",
        "jobs.edit_job_subtitle": "Update your job information",
        "jobs.please_enter_job_name": "Please enter a job name",
        "jobs.please_enter_hourly_rate": "Please enter an hourly rate",
        "jobs.please_enter_valid_hourly_rate": "Please enter a valid hourly rate",
        "jobs.job_updated_success": "Job '%@' updated successfully!",
        "jobs.failed_to_update_job": "Failed to update job: %@",
        "jobs.no_bonuses_added": "No bonuses added",
        "jobs.add_bonuses_tip": "Tap + to add bonus opportunities",
        
        // History
        "history.title": "History",
        "history.no_shifts": "No shifts found",
        "history.add_first_shift": "Start tracking your work to see your history here",
        "history.export_data": "Export Data",
        "history.export_csv": "Export as CSV",
        "history.export_pdf": "Export as PDF",
        "history.total_earnings": "Total Earnings",
        "history.total_hours": "Total Hours",
        "history.average_rate": "Average Rate",
        "history.shifts_count": "Shifts",
        "history.period_all": "All",
        "history.period_today": "Today",
        "history.period_this_week": "This Week",
        "history.period_this_month": "This Month",
        "history.period_last_30_days": "Last 30 Days",
        
        // Analytics
        "analytics.title": "Analytics",
        "analytics.earnings_overview": "Earnings Overview",
        "analytics.hours_worked": "Hours Worked",
        "analytics.average_hourly_rate": "Average Hourly Rate",
        "analytics.earnings_breakdown": "Earnings Breakdown",
        "analytics.top_jobs": "Top Jobs",
        "analytics.insights": "Insights",
        "analytics.regular_shifts": "Regular Shifts",
        "analytics.overtime_shifts": "Overtime Shifts",
        "analytics.special_shifts": "Special Shifts",
        "analytics.bonus_earnings": "Bonus Earnings",
        "analytics.this_week": "This Week",
        "analytics.this_month": "This Month",
        "analytics.last_3_months": "Last 3 Months",
        "analytics.this_year": "This Year",
        "analytics.all_time": "All Time",
        "analytics.filter_by_job": "Filter by Job",
        "analytics.all_jobs": "All Jobs",
        "analytics.no_data": "No data available",
        "analytics.start_tracking_to_see_analytics": "Start tracking to see your analytics",
        
        // Settings
        "settings.title": "Settings",
        "settings.notifications": "Notifications",
        "settings.language": "Language",
        "settings.currency": "Currency",
        "settings.app_info": "App Information",
        "settings.version": "Version",
        "settings.build": "Build",
        "settings.description": "Track your work hours, calculate earnings, and manage your time effectively. Built with SwiftUI and Core Data for offline-first functionality.",
        "settings.manage_reminders": "Manage Reminders",
        "settings.language_currency": "Language & Currency",
        
        // Reminders
        "reminders.title": "Reminders",
        "reminders.notification_status": "Notification Status",
        "reminders.enabled": "Enabled",
        "reminders.disabled": "Disabled",
        "reminders.enable": "Enable",
        "reminders.daily_reminder": "Daily Reminder",
        "reminders.shift_reminders": "Shift Reminders",
        "reminders.weekly_summary": "Weekly Summary",
        "reminders.test_notification": "Test Notification",
        "reminders.permission_required": "Permission Required",
        "reminders.grant_permission": "Grant Permission",
        "reminders.reminder_time": "Reminder Time",
        "reminders.shift_start_reminder": "Shift Start Reminder",
        "reminders.shift_end_reminder": "Shift End Reminder",
        "reminders.weekly_summary_reminder": "Weekly Summary Reminder",
        "reminders.notification_sent": "Test notification sent!",
        "reminders.error_sending": "Error sending notification",
        "reminders.permission_denied": "Notification permission denied",
        "reminders.settings_required": "Please enable notifications in Settings",
        
        // Earnings Goals
        "goals.title": "Earnings Goals",
        "goals.daily_goal": "Daily Goal",
        "goals.weekly_goal": "Weekly Goal",
        "goals.monthly_goal": "Monthly Goal",
        "goals.set_goal": "Set Goal",
        "goals.goal_achieved": "Goal Achieved!",
        "goals.goal_progress": "Goal Progress",
        "goals.remaining": "Remaining",
        "goals.over_goal": "Over Goal",
        "goals.goal_amount": "Goal Amount",
        "goals.current_earnings": "Current Earnings",
        "goals.progress_percentage": "Progress",
        "goals.daily": "Daily",
        "goals.weekly": "Weekly",
        "goals.monthly": "Monthly",
        "goals.goal_saved": "Goal saved successfully",
        "goals.goal_updated": "Goal updated successfully",
        "goals.error_saving": "Error saving goal",
        
        // Common
        "common.loading": "Loading...",
        "common.retry": "Retry",
        "common.close": "Close",
        "common.next": "Next",
        "common.previous": "Previous",
        "common.continue": "Continue",
        "common.finish": "Finish",
        "common.back": "Back",
        "common.forward": "Forward",
        "common.refresh": "Refresh",
        "common.search": "Search",
        "common.filter": "Filter",
        "common.sort": "Sort",
        "common.clear": "Clear",
        "common.reset": "Reset",
        "common.apply": "Apply",
        "common.confirm": "Confirm",
        "common.discard": "Discard",
        "common.undo": "Undo",
        "common.redo": "Redo",
        
        // Manual Shift
        "shifts.add_manual_shift": "Add Manual Shift",
        "shifts.record_past_work": "Record past work hours",
        "shifts.job_selection": "Job Selection",
        "shifts.select_job": "Select Job",
        "shifts.choose_work_position": "Choose your work position",
        "shifts.time_details": "Time Details",
        "shifts.start_time": "Start Time",
        "shifts.end_time": "End Time",
        "shifts.duration": "Duration:",
        "shifts.additional_details": "Additional Details",
        "shifts.notes_optional": "Notes (Optional)",
        "shifts.add_notes_placeholder": "Add notes about this shift...",
        "shifts.bonus_amount": "Bonus Amount",
        "shifts.earnings_preview": "Earnings Preview",
        "shifts.base_pay": "Base Pay",
        "shifts.bonus": "Bonus",
        "shifts.total_earnings": "Total Earnings",
        "shifts.save": "Save",
        "shifts.please_select_job": "Please select a job",
        "shifts.end_time_after_start": "End time must be after start time",
        "shifts.duration_greater_than_zero": "Shift duration must be greater than 0",
        "shifts.shift_added_success": "Shift added successfully!",
        "shifts.failed_to_save_shift": "Failed to save shift: %@",
        "shifts.select_job_title": "Select Job",
        "shifts.done": "Done",
        
        // Edit Job
        
        // Add Job validation messages
        "jobs.enter_job_name_warning": "Please enter a job name",
        "jobs.enter_hourly_rate_warning": "Please enter an hourly rate",
        "jobs.enter_valid_hourly_rate_warning": "Please enter a valid hourly rate",
        "jobs.job_added_success": "Job '%@' added successfully!",
        "jobs.failed_to_save_job": "Failed to save job: %@",
        
        // Onboarding
        "onboarding.previous": "Previous",
        "onboarding.next": "Next",
        "onboarding.get_started": "Get Started",
        
        // Earnings Goals
        "earnings_goals.title": "Earnings Goals",
        "earnings_goals.subtitle": "Set and track your financial targets",
        "earnings_goals.overview": "Goals Overview",
        "earnings_goals.today_progress": "Today's Progress",
        "earnings_goals.this_week": "This Week",
        "earnings_goals.this_month": "This Month",
        "earnings_goals.progress": "Progress",
        "earnings_goals.goal_achieved": "Goal Achieved! 🎉",
        "earnings_goals.summary": "Progress Summary",
        "earnings_goals.completed": "Goals Completed",
        "earnings_goals.total_earnings": "Total Earnings",
        "earnings_goals.average_daily": "Average Daily",
        "earnings_goals.motivation": "Motivation",
        "earnings_goals.edit_goal": "Edit Goal",
        "common.done": "Done",
        "common.cancel": "Cancel",
        "common.save": "Save",
        "common.edit": "Edit",
        "earnings_goals.goal_amount": "Goal Amount",
        "earnings_goals.quick_set": "Quick Set",
        "earnings_goals.save_goal": "Save Goal",
        "import.title": "Import Data",
        "import.subtitle": "Import your existing time tracking data from other apps",
        "import.select_type": "Select Import Type",
        "shifts.edit_shift": "Edit Shift",
        "shifts.edit_shift_subtitle": "Modify your shift details",
        "shifts.job": "Job",
        "shifts.hours": "hours",
        "shifts.notes_placeholder": "Add notes about this shift...",
        "common.saving": "Saving...",
        "shifts.shift_updated_success": "Shift updated successfully!",
        
        // History View
        "history.no_history": "No History Yet",
        "history.no_history_subtitle": "Your shift history will appear here once you start tracking time.",
        "history.start_time": "Start",
        "history.end_time": "End",
        "history.bonuses": "Bonuses",
        "history.edit": "Edit",
        "history.export_options": "Export Options",
        "history.export_subtitle": "Choose how you want to export your shift data",
        "history.no_analytics": "No Analytics Data",
    ]
    
    // MARK: - Hebrew Strings
    
    private let hebrewStrings: [String: String] = [
        // Navigation
        "nav.dashboard": "לוח בקרה",
        "nav.time_tracking": "מעקב זמן",
        "nav.jobs": "עבודות",
        "nav.history": "היסטוריה",
        "nav.analytics": "אנליטיקה",
        "nav.settings": "הגדרות",
        
        // Dashboard
        "dashboard.title": "לוח בקרה",
        "dashboard.welcome": "ברוכים הבאים ל-TIS",
        "dashboard.good_morning": "בוקר טוב",
        "dashboard.good_afternoon": "צהריים טובים",
        "dashboard.good_evening": "ערב טוב",
        "dashboard.current_status": "סטטוס נוכחי",
        "dashboard.quick_actions": "פעולות מהירות",
        "dashboard.jobs_overview": "סקירת עבודות",
        "dashboard.recent_activity": "פעילות אחרונה",
        "dashboard.earnings_goals": "יעדי הכנסות",
        "dashboard.start_tracking": "התחל מעקב",
        "dashboard.add_job": "הוסף עבודה",
        "dashboard.view_history": "צפה בהיסטוריה",
        "dashboard.tracking": "מעקב",
        "dashboard.ready": "מוכן",
        "dashboard.live": "חי",
        "dashboard.job": "עבודה:",
        "dashboard.duration": "משך:",
        "dashboard.earnings": "הכנסות:",
        "dashboard.no_jobs": "אין עבודות עדיין",
        "dashboard.add_first_job": "הוסף את העבודה הראשונה שלך כדי להתחיל",
        "dashboard.no_recent_activity": "אין פעילות אחרונה",
        "dashboard.start_tracking_to_see_activity": "התחל מעקב כדי לראות את הפעילות שלך כאן",
        
        // Time Tracking
        "time_tracking.title": "מעקב זמן",
        "time_tracking.start_shift": "התחל משמרת",
        "time_tracking.end_shift": "סיים משמרת",
        "time_tracking.select_job": "בחר עבודה",
        "time_tracking.shift_type": "סוג משמרת",
        "time_tracking.notes": "הערות",
        "time_tracking.tracking": "מעקב",
        "time_tracking.ready": "מוכן",
        "time_tracking.regular": "רגיל",
        "time_tracking.overtime": "שעות נוספות",
        "time_tracking.special": "אירוע מיוחד",
        "time_tracking.flexible": "גמיש",
        "time_tracking.no_jobs_available": "אין עבודות זמינות",
        "time_tracking.add_job_first": "הוסף עבודה קודם כדי להתחיל מעקב",
        "time_tracking.shift_notes_placeholder": "הוסף הערות למשמרת זו...",
        "time_tracking.character_count": "תווים",
        
        // Jobs
        "jobs.title": "עבודות",
        "jobs.add_job": "הוסף עבודה",
        "jobs.edit_job": "ערוך עבודה",
        "jobs.delete_job": "מחק עבודה",
        "jobs.job_name": "שם העבודה",
        "jobs.hourly_rate": "שכר שעתי",
        "jobs.bonuses": "בונוסים",
        "jobs.total_hours": "סה\"כ שעות",
        "jobs.total_earnings": "סה\"כ הכנסות",
        "jobs.no_jobs": "אין עבודות עדיין",
        "jobs.add_first_job": "הוסף את העבודה הראשונה שלך כדי להתחיל",
        "jobs.job_name_placeholder": "הכנס שם עבודה",
        "jobs.hourly_rate_placeholder": "0.00",
        "jobs.bonus_name_placeholder": "שם בונוס",
        "jobs.bonus_amount_placeholder": "0.00",
        "jobs.add_bonus": "הוסף בונוס",
        "jobs.remove_bonus": "הסר",
        "jobs.save_job": "שמור עבודה",
        "jobs.cancel": "בטל",
        "jobs.delete": "מחק",
        "jobs.edit": "ערוך",
        "jobs.job_name_required": "שם העבודה נדרש",
        "jobs.hourly_rate_required": "שכר שעתי נדרש",
        "jobs.hourly_rate_invalid": "אנא הכנס שכר שעתי תקין",
        "jobs.job_saved": "העבודה נשמרה בהצלחה",
        "jobs.job_deleted": "העבודה נמחקה בהצלחה",
        "jobs.error_saving": "שגיאה בשמירת העבודה",
        "jobs.error_deleting": "שגיאה במחיקת העבודה",
        "jobs.add_job_subtitle": "צור תפקיד עבודה חדש למעקב",
        "jobs.job_information": "פרטי עבודה",
        "jobs.bonuses_optional": "בונוסים (אופציונלי)",
        "jobs.no_bonuses": "לא נוספו בונוסים",
        "jobs.add_bonus_tip": "הקש על + כדי להוסיף אפשרויות בונוס",
        "jobs.preview": "תצוגה מקדימה",
        "jobs.bonus_name": "שם הבונוס",
        "jobs.amount": "סכום",
        
        // History
        "history.title": "היסטוריה",
        "history.no_shifts": "לא נמצאו משמרות",
        "history.add_first_shift": "התחל לעקוב אחר העבודה שלך כדי לראות את ההיסטוריה כאן",
        "history.export_data": "ייצא נתונים",
        "history.export_csv": "ייצא כ-CSV",
        "history.export_pdf": "ייצא כ-PDF",
        "history.total_earnings": "הכנסות כוללות",
        "history.total_hours": "שעות כוללות",
        "history.average_rate": "שכר ממוצע",
        "history.shifts_count": "משמרות",
        "history.period_all": "הכל",
        "history.period_today": "היום",
        "history.period_this_week": "השבוע",
        "history.period_this_month": "החודש",
        "history.period_last_30_days": "30 הימים האחרונים",
        
        // Analytics
        "analytics.title": "אנליטיקה",
        "analytics.earnings_overview": "סקירת הכנסות",
        "analytics.hours_worked": "שעות עבודה",
        "analytics.average_hourly_rate": "שכר שעתי ממוצע",
        "analytics.earnings_breakdown": "פירוט הכנסות",
        "analytics.top_jobs": "עבודות מובילות",
        "analytics.insights": "תובנות",
        "analytics.regular_shifts": "משמרות רגילות",
        "analytics.overtime_shifts": "משמרות שעות נוספות",
        "analytics.special_shifts": "משמרות מיוחדות",
        "analytics.bonus_earnings": "הכנסות בונוס",
        "analytics.this_week": "השבוע",
        "analytics.this_month": "החודש",
        "analytics.last_3_months": "3 החודשים האחרונים",
        "analytics.this_year": "השנה",
        "analytics.all_time": "כל הזמנים",
        "analytics.filter_by_job": "סנן לפי עבודה",
        "analytics.all_jobs": "כל העבודות",
        "analytics.no_data": "אין נתונים זמינים",
        "analytics.start_tracking_to_see_analytics": "התחל מעקב כדי לראות את האנליטיקה שלך",
        
        // Settings
        "settings.title": "הגדרות",
        "settings.notifications": "התראות",
        "settings.language": "שפה",
        "settings.currency": "מטבע",
        "settings.app_info": "מידע על האפליקציה",
        "settings.version": "גרסה",
        "settings.build": "בנייה",
        "settings.description": "עקוב אחר שעות העבודה שלך, חשב הכנסות ונהל את הזמן שלך ביעילות. נבנה עם SwiftUI ו-Core Data לפונקציונליות אופליין.",
        "settings.manage_reminders": "נהל תזכורות",
        "settings.language_currency": "שפה ומטבע",
        
        // Reminders
        "reminders.title": "תזכורות",
        "reminders.notification_status": "סטטוס התראות",
        "reminders.enabled": "מופעל",
        "reminders.disabled": "מבוטל",
        "reminders.enable": "הפעל",
        "reminders.daily_reminder": "תזכורת יומית",
        "reminders.shift_reminders": "תזכורות משמרת",
        "reminders.weekly_summary": "סיכום שבועי",
        "reminders.test_notification": "בדוק התראה",
        "reminders.permission_required": "נדרשת הרשאה",
        "reminders.grant_permission": "הענק הרשאה",
        "reminders.reminder_time": "זמן תזכורת",
        "reminders.shift_start_reminder": "תזכורת התחלת משמרת",
        "reminders.shift_end_reminder": "תזכורת סיום משמרת",
        "reminders.weekly_summary_reminder": "תזכורת סיכום שבועי",
        "reminders.notification_sent": "התראה נשלחה!",
        "reminders.error_sending": "שגיאה בשליחת התראה",
        "reminders.permission_denied": "הרשאת התראות נדחתה",
        "reminders.settings_required": "אנא הפעל התראות בהגדרות",
        
        // Earnings Goals
        "goals.title": "יעדי הכנסות",
        "goals.daily_goal": "יעד יומי",
        "goals.weekly_goal": "יעד שבועי",
        "goals.monthly_goal": "יעד חודשי",
        "goals.set_goal": "הגדר יעד",
        "goals.goal_achieved": "היעד הושג!",
        "goals.goal_progress": "התקדמות יעד",
        "goals.remaining": "נותר",
        "goals.over_goal": "מעל היעד",
        "goals.goal_amount": "סכום יעד",
        "goals.current_earnings": "הכנסות נוכחיות",
        "goals.progress_percentage": "התקדמות",
        "goals.daily": "יומי",
        "goals.weekly": "שבועי",
        "goals.monthly": "חודשי",
        "goals.goal_saved": "היעד נשמר בהצלחה",
        "goals.goal_updated": "היעד עודכן בהצלחה",
        "goals.error_saving": "שגיאה בשמירת היעד",
        
        // Common
        "common.loading": "טוען...",
        "common.retry": "נסה שוב",
        "common.close": "סגור",
        "common.next": "הבא",
        "common.previous": "הקודם",
        "common.continue": "המשך",
        "common.finish": "סיים",
        "common.back": "חזור",
        "common.forward": "קדימה",
        "common.refresh": "רענן",
        "common.search": "חיפוש",
        "common.filter": "סינון",
        "common.sort": "מיון",
        "common.clear": "נקה",
        "common.reset": "איפוס",
        "common.apply": "החל",
        "common.confirm": "אשר",
        "common.discard": "התעלם",
        "common.undo": "בטל",
        "common.redo": "חזור על",
        
        // Manual Shift
        "shifts.add_manual_shift": "הוסף משמרת ידנית",
        "shifts.record_past_work": "רשום שעות עבודה קודמות",
        "shifts.job_selection": "בחירת עבודה",
        "shifts.select_job": "בחר עבודה",
        "shifts.choose_work_position": "בחר את תפקיד העבודה שלך",
        "shifts.time_details": "פרטי זמן",
        "shifts.start_time": "שעת התחלה",
        "shifts.end_time": "שעת סיום",
        "shifts.duration": "משך:",
        "shifts.additional_details": "פרטים נוספים",
        "shifts.notes_optional": "הערות (אופציונלי)",
        "shifts.add_notes_placeholder": "הוסף הערות על המשמרת...",
        "shifts.bonus_amount": "סכום בונוס",
        "shifts.earnings_preview": "תצוגת הכנסות",
        "shifts.base_pay": "תשלום בסיסי",
        "shifts.bonus": "בונוס",
        "shifts.total_earnings": "הכנסות כוללות",
        "shifts.save": "שמור",
        "shifts.please_select_job": "אנא בחר עבודה",
        "shifts.end_time_after_start": "שעת הסיום חייבת להיות אחרי שעת ההתחלה",
        "shifts.duration_greater_than_zero": "משך המשמרת חייב להיות גדול מ-0",
        "shifts.shift_added_success": "המשמרת נוספה בהצלחה!",
        "shifts.failed_to_save_shift": "נכשל בשמירת המשמרת: %@",
        "shifts.select_job_title": "בחר עבודה",
        "shifts.done": "סיום",
        
        // Edit Job
        
        // Add Job validation messages
        "jobs.enter_job_name_warning": "אנא הכנס שם עבודה",
        "jobs.enter_hourly_rate_warning": "אנא הכנס שכר שעתי",
        "jobs.enter_valid_hourly_rate_warning": "אנא הכנס שכר שעתי תקין",
        "jobs.job_added_success": "העבודה '%@' נוספה בהצלחה!",
        "jobs.failed_to_save_job": "נכשל בשמירת העבודה: %@",
        
        // Onboarding
        "onboarding.previous": "הקודם",
        "onboarding.next": "הבא",
        "onboarding.get_started": "בואו נתחיל",
        
        // Earnings Goals
        "earnings_goals.title": "יעדי רווחים",
        "earnings_goals.subtitle": "הגדר ועקוב אחר המטרות הפיננסיות שלך",
        "earnings_goals.overview": "סקירת יעדים",
        "earnings_goals.today_progress": "התקדמות היום",
        "earnings_goals.this_week": "השבוע",
        "earnings_goals.this_month": "החודש",
        "earnings_goals.progress": "התקדמות",
        "earnings_goals.goal_achieved": "יעד הושג! 🎉",
        "earnings_goals.summary": "סיכום התקדמות",
        "earnings_goals.completed": "יעדים שהושלמו",
        "earnings_goals.total_earnings": "סה״כ רווחים",
        "earnings_goals.average_daily": "ממוצע יומי",
        "earnings_goals.motivation": "מוטיבציה",
        "earnings_goals.edit_goal": "ערוך יעד",
        "common.done": "סיום",
        "common.cancel": "ביטול",
        "common.save": "שמור",
        "common.edit": "ערוך",
        "earnings_goals.goal_amount": "סכום יעד",
        "earnings_goals.quick_set": "הגדרה מהירה",
        "earnings_goals.save_goal": "שמור יעד",
        "import.title": "ייבוא נתונים",
        "import.subtitle": "ייבא את נתוני מעקב הזמן שלך מאפליקציות אחרות",
        "import.select_type": "בחר סוג ייבוא",
        "shifts.edit_shift": "ערוך משמרת",
        "shifts.edit_shift_subtitle": "ערוך את פרטי המשמרת שלך",
        "shifts.job": "עבודה",
        "shifts.hours": "שעות",
        "shifts.notes_placeholder": "הוסף הערות על המשמרת...",
        "common.saving": "שומר...",
        "shifts.shift_updated_success": "המשמרת עודכנה בהצלחה!",
        
        // Job labels
        "jobs.job_label": "עבודה:",
        "jobs.rate_label": "שכר:",
        "jobs.bonuses_label": "בונוסים:",
        "jobs.shifts_count": "משמרות",
        "jobs.edit_job_subtitle": "עדכן את פרטי העבודה שלך",
        "jobs.please_enter_job_name": "אנא הכנס שם עבודה",
        "jobs.please_enter_hourly_rate": "אנא הכנס שכר שעתי",
        "jobs.please_enter_valid_hourly_rate": "אנא הכנס שכר שעתי תקין",
        "jobs.job_updated_success": "העבודה '%@' עודכנה בהצלחה!",
        "jobs.failed_to_update_job": "נכשל בעדכון העבודה: %@",
        "jobs.no_bonuses_added": "לא נוספו בונוסים",
        "jobs.add_bonuses_tip": "הקש על + כדי להוסיף אפשרויות בונוס",
        
        // History View
        "history.no_history": "אין היסטוריה עדיין",
        "history.no_history_subtitle": "היסטוריית המשמרות שלך תופיע כאן ברגע שתתחיל לעקוב אחר זמן",
        "history.start_time": "התחלה",
        "history.end_time": "סיום",
        "history.bonuses": "בונוסים",
        "history.edit": "ערוך",
        "history.export_options": "אפשרויות ייצוא",
        "history.export_subtitle": "בחר איך אתה רוצה לייצא את נתוני המשמרות שלך",
        "history.no_analytics": "אין נתוני אנליטיקה"
    ]
}

// MARK: - View Extensions

extension View {
    func localizedString(for key: String) -> String {
        LocalizationManager.shared.localizedString(for: key)
    }
}

