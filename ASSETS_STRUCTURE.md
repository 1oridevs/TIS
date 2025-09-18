# TIS App - Assets Structure

## 📁 Assets.xcassets Directory Structure

```
Assets.xcassets/
├── Contents.json
├── AppIcon.appiconset/
│   ├── Contents.json
│   ├── AppIcon-20.png
│   ├── AppIcon-29.png
│   ├── AppIcon-40.png
│   ├── AppIcon-60.png
│   ├── AppIcon-76.png
│   ├── AppIcon-83.5.png
│   └── AppIcon-1024.png
├── AccentColor.colorset/
│   └── Contents.json
├── ShiftTypeIcons.imageset/
│   ├── Contents.json
│   ├── regular-shift.png
│   ├── overtime-shift.png
│   ├── special-event-shift.png
│   └── flexible-shift.png
├── FeatureIcons.imageset/
│   ├── Contents.json
│   ├── time-tracking.png
│   ├── job-management.png
│   ├── analytics.png
│   ├── history.png
│   └── settings.png
├── AchievementBadges.imageset/
│   ├── Contents.json
│   ├── first-shift-badge.png
│   ├── 10-hours-badge.png
│   ├── week-complete-badge.png
│   ├── month-complete-badge.png
│   └── overtime-badge.png
├── BackgroundPatterns.imageset/
│   ├── Contents.json
│   ├── geometric-pattern.png
│   ├── dots-pattern.png
│   └── lines-pattern.png
└── OnboardingIllustrations.imageset/
    ├── Contents.json
    ├── welcome-illustration.png
    ├── add-job-illustration.png
    ├── start-tracking-illustration.png
    ├── view-history-illustration.png
    └── analytics-illustration.png
```

## 🎯 Image Usage in Code

### **Shift Type Icons:**
```swift
Image("regular-shift")
Image("overtime-shift")
Image("special-event-shift")
Image("flexible-shift")
```

### **Feature Icons:**
```swift
Image("time-tracking")
Image("job-management")
Image("analytics")
Image("history")
Image("settings")
```

### **Achievement Badges:**
```swift
Image("first-shift-badge")
Image("10-hours-badge")
Image("week-complete-badge")
Image("month-complete-badge")
Image("overtime-badge")
```

### **Background Patterns:**
```swift
Image("geometric-pattern")
Image("dots-pattern")
Image("lines-pattern")
```

### **Onboarding Illustrations:**
```swift
Image("welcome-illustration")
Image("add-job-illustration")
Image("start-tracking-illustration")
Image("view-history-illustration")
Image("analytics-illustration")
```

## 📏 Size Requirements

| Image Type | Base Size | @2x Size | @3x Size |
|------------|-----------|----------|----------|
| App Icon | 1024x1024 | - | - |
| Feature Icons | 32x32 | 64x64 | 96x96 |
| Shift Icons | 64x64 | 128x128 | 192x192 |
| Achievement Badges | 48x48 | 96x96 | 144x144 |
| Background Patterns | 200x200 | 400x400 | 600x600 |
| Onboarding Illustrations | 300x300 | 600x600 | 900x900 |

## 🎨 Color Palette

- **Primary Blue**: #007AFF
- **Success Green**: #00C851
- **Warning Orange**: #FF9500
- **Purple**: #AF52DE
- **Gold**: #FFD700
- **Silver**: #C0C0C0
- **Gray**: #8E8E93
- **Light Gray**: #F0F0F0

## 📝 Notes

1. All images should be PNG format with transparency where appropriate
2. Follow iOS Human Interface Guidelines for icon design
3. Ensure all icons are recognizable at small sizes
4. Maintain consistent visual style across all assets
5. Test on both light and dark backgrounds
6. Use the provided prompts in IMAGE_PROMPTS.md for creation
