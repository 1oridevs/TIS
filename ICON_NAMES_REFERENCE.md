# 🎨 TIS App - Icon Names Reference

## 📱 **App Icon Files (AppIcon.appiconset)**
- `AppIcon-20.png` (20x20)
- `AppIcon-20@3x.png` (60x60)
- `AppIcon-29.png` (58x58)
- `AppIcon-29@3x.png` (87x87)
- `AppIcon-40.png` (80x80)
- `AppIcon-40@3x.png` (120x120)
- `AppIcon-60@2x.png` (120x120)
- `AppIcon-60@3x.png` (180x180)
- `AppIcon-76.png` (76x76)
- `AppIcon-76@2x.png` (152x152)
- `AppIcon-83.5@2x.png` (167x167)
- `AppIcon-1024.png` (1024x1024)

## ⏰ **Shift Type Icons**

### **RegularShift.imageset**
- `regular-shift.png` (64x64)
- `regular-shift@2x.png` (128x128)
- `regular-shift@3x.png` (192x192)

### **OvertimeShift.imageset**
- `overtime-shift.png` (64x64)
- `overtime-shift@2x.png` (128x128)
- `overtime-shift@3x.png` (192x192)

### **SpecialEventShift.imageset**
- `special-event-shift.png` (64x64)
- `special-event-shift@2x.png` (128x128)
- `special-event-shift@3x.png` (192x192)

### **FlexibleShift.imageset**
- `flexible-shift.png` (64x64)
- `flexible-shift@2x.png` (128x128)
- `flexible-shift@3x.png` (192x192)

## 🎯 **Feature Icons**

### **TimeTrackingIcon.imageset**
- `time-tracking.png` (32x32)
- `time-tracking@2x.png` (64x64)
- `time-tracking@3x.png` (96x96)

### **JobManagementIcon.imageset**
- `job-management.png` (32x32)
- `job-management@2x.png` (64x64)
- `job-management@3x.png` (96x96)

### **AnalyticsIcon.imageset**
- `analytics.png` (32x32)
- `analytics@2x.png` (64x64)
- `analytics@3x.png` (96x96)

### **HistoryIcon.imageset**
- `history.png` (32x32)
- `history@2x.png` (64x64)
- `history@3x.png` (96x96)

### **SettingsIcon.imageset**
- `settings.png` (32x32)
- `settings@2x.png` (64x64)
- `settings@3x.png` (96x96)

## 🏆 **Achievement Badges**

### **FirstShiftBadge.imageset**
- `first-shift-badge.png` (48x48)
- `first-shift-badge@2x.png` (96x96)
- `first-shift-badge@3x.png` (144x144)

### **TenHoursBadge.imageset**
- `10-hours-badge.png` (48x48)
- `10-hours-badge@2x.png` (96x96)
- `10-hours-badge@3x.png` (144x144)

### **WeekCompleteBadge.imageset**
- `week-complete-badge.png` (48x48)
- `week-complete-badge@2x.png` (96x96)
- `week-complete-badge@3x.png` (144x144)

### **MonthCompleteBadge.imageset**
- `month-complete-badge.png` (48x48)
- `month-complete-badge@2x.png` (96x96)
- `month-complete-badge@3x.png` (144x144)

### **OvertimeBadge.imageset**
- `overtime-badge.png` (48x48)
- `overtime-badge@2x.png` (96x96)
- `overtime-badge@3x.png` (144x144)

## 🎨 **Background Patterns**

### **GeometricPattern.imageset**
- `geometric-pattern.png` (200x200)
- `geometric-pattern@2x.png` (400x400)
- `geometric-pattern@3x.png` (600x600)

### **DotsPattern.imageset**
- `dots-pattern.png` (200x200)
- `dots-pattern@2x.png` (400x400)
- `dots-pattern@3x.png` (600x600)

### **LinesPattern.imageset**
- `lines-pattern.png` (200x200)
- `lines-pattern@2x.png` (400x400)
- `lines-pattern@3x.png` (600x600)

## 📚 **Onboarding Illustrations**

### **WelcomeIllustration.imageset**
- `welcome-illustration.png` (300x300)
- `welcome-illustration@2x.png` (600x600)
- `welcome-illustration@3x.png` (900x900)

### **AddJobIllustration.imageset**
- `add-job-illustration.png` (300x300)
- `add-job-illustration@2x.png` (600x600)
- `add-job-illustration@3x.png` (900x900)

### **StartTrackingIllustration.imageset**
- `start-tracking-illustration.png` (300x300)
- `start-tracking-illustration@2x.png` (600x600)
- `start-tracking-illustration@3x.png` (900x900)

### **ViewHistoryIllustration.imageset**
- `view-history-illustration.png` (300x300)
- `view-history-illustration@2x.png` (600x600)
- `view-history-illustration@3x.png` (900x900)

### **AnalyticsIllustration.imageset**
- `analytics-illustration.png` (300x300)
- `analytics-illustration@2x.png` (600x600)
- `analytics-illustration@3x.png` (900x900)

## 🚀 **How to Use in Xcode**

1. **Open Xcode** and navigate to `Assets.xcassets`
2. **Find the imageset** you want to add icons to
3. **Drag and drop** the icon files into the appropriate slots:
   - **1x slot**: Base size (e.g., `regular-shift.png`)
   - **2x slot**: Double size (e.g., `regular-shift@2x.png`)
   - **3x slot**: Triple size (e.g., `regular-shift@3x.png`)
4. **Verify** the filenames match exactly as listed above
5. **Test** the app to ensure icons display correctly

## 📝 **Usage in Code**

```swift
// Shift type icons
Image("RegularShift")
Image("OvertimeShift")
Image("SpecialEventShift")
Image("FlexibleShift")

// Feature icons
Image("TimeTrackingIcon")
Image("JobManagementIcon")
Image("AnalyticsIcon")
Image("HistoryIcon")
Image("SettingsIcon")

// Achievement badges
Image("FirstShiftBadge")
Image("TenHoursBadge")
Image("WeekCompleteBadge")
Image("MonthCompleteBadge")
Image("OvertimeBadge")

// Background patterns
Image("GeometricPattern")
Image("DotsPattern")
Image("LinesPattern")

// Onboarding illustrations
Image("WelcomeIllustration")
Image("AddJobIllustration")
Image("StartTrackingIllustration")
Image("ViewHistoryIllustration")
Image("AnalyticsIllustration")
```

## ✅ **Checklist**

- [ ] All icon files named exactly as specified
- [ ] Proper sizes (1x, 2x, 3x versions)
- [ ] PNG format with transparency where needed
- [ ] Files placed in correct imageset folders
- [ ] No "unassigned child" warnings in Xcode
- [ ] Icons display correctly in app
- [ ] All imagesets have proper Contents.json files
