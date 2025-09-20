# 🎨 TIS App - Icon Integration Guide

## 📁 Folder Structure

Place your icons in the following organized structure:

```
icons/
├── app-icon/                    # App icon files
│   ├── AppIcon-20.png          # 20x20
│   ├── AppIcon-29.png          # 29x29
│   ├── AppIcon-40.png          # 40x40
│   ├── AppIcon-60.png          # 60x60
│   ├── AppIcon-76.png          # 76x76
│   ├── AppIcon-83.5.png        # 83.5x83.5
│   └── AppIcon-1024.png        # 1024x1024
├── shift-types/                 # Shift type icons
│   ├── regular-shift.png       # 64x64 base
│   ├── overtime-shift.png      # 64x64 base
│   ├── special-event-shift.png # 64x64 base
│   └── flexible-shift.png      # 64x64 base
├── feature-icons/               # Feature icons
│   ├── time-tracking.png       # 32x32 base
│   ├── job-management.png      # 32x32 base
│   ├── analytics.png           # 32x32 base
│   ├── history.png             # 32x32 base
│   └── settings.png            # 32x32 base
├── achievement-badges/          # Achievement badges
│   ├── first-shift-badge.png   # 48x48 base
│   ├── 10-hours-badge.png      # 48x48 base
│   ├── week-complete-badge.png # 48x48 base
│   ├── month-complete-badge.png# 48x48 base
│   └── overtime-badge.png      # 48x48 base
├── background-patterns/         # Background patterns
│   ├── geometric-pattern.png   # 200x200 tileable
│   ├── dots-pattern.png        # 200x200 tileable
│   └── lines-pattern.png       # 200x200 tileable
└── onboarding-illustrations/    # Onboarding illustrations
    ├── welcome-illustration.png # 300x300 base
    ├── add-job-illustration.png # 300x300 base
    ├── start-tracking-illustration.png # 300x300 base
    ├── view-history-illustration.png # 300x300 base
    └── analytics-illustration.png # 300x300 base
```

## 🚀 Integration Steps

### **Step 1: Place Your Icons**
1. **Copy your icon files** into the appropriate folders above
2. **Name them exactly** as shown in the structure
3. **Ensure proper sizes** (base sizes are listed)

### **Step 2: Run the Integration Script**
```bash
# This will automatically copy and organize your icons
./integrate_icons.sh
```

### **Step 3: Verify Integration**
1. **Open Xcode** and check Assets.xcassets
2. **Verify all imagesets** have the correct files
3. **Test the app** to ensure icons display properly

## 📏 Size Requirements

| Icon Type | Base Size | @2x Size | @3x Size |
|-----------|-----------|----------|----------|
| App Icon | 1024x1024 | - | - |
| Feature Icons | 32x32 | 64x64 | 96x96 |
| Shift Icons | 64x64 | 128x128 | 192x192 |
| Achievement Badges | 48x48 | 96x96 | 144x144 |
| Background Patterns | 200x200 | 400x400 | 600x600 |
| Onboarding Illustrations | 300x300 | 600x600 | 900x900 |

## 🎨 Design Guidelines

### **App Icon:**
- **Style**: Modern, professional, clean
- **Colors**: Blue (#007AFF) and Green (#00C851)
- **Elements**: Clock/timer + money symbol
- **Format**: PNG with transparency

### **Shift Type Icons:**
- **Regular**: Blue clock (9-5 hours)
- **Overtime**: Orange clock with exclamation
- **Special Event**: Purple star or special symbol
- **Flexible**: Green clock with curved elements

### **Feature Icons:**
- **Time Tracking**: Blue play/stop controls
- **Job Management**: Green briefcase
- **Analytics**: Purple charts/graphs
- **History**: Orange clock with arrow
- **Settings**: Gray gear/cog

### **Achievement Badges:**
- **Circular design** with numbers/symbols
- **Color-coded** by achievement type
- **Celebration elements** (stars, etc.)

## 🔧 Troubleshooting

### **Common Issues:**
1. **"Unassigned child" warning**: Remove extra files from imageset folders
2. **Icons not showing**: Check file names match exactly
3. **Wrong sizes**: Ensure proper @2x and @3x versions
4. **Transparency issues**: Use PNG format with proper alpha channel

### **File Naming:**
- **Use lowercase** with hyphens
- **No spaces** in filenames
- **Match exactly** the names in the structure above

## 📱 Usage in Code

Once integrated, use icons like this:

```swift
// Shift type icons
Image("regular-shift")
Image("overtime-shift")
Image("special-event-shift")
Image("flexible-shift")

// Feature icons
Image("time-tracking")
Image("job-management")
Image("analytics")
Image("history")
Image("settings")

// Achievement badges
Image("first-shift-badge")
Image("10-hours-badge")
Image("week-complete-badge")

// Background patterns
Image("geometric-pattern")
Image("dots-pattern")
Image("lines-pattern")

// Onboarding illustrations
Image("welcome-illustration")
Image("add-job-illustration")
Image("start-tracking-illustration")
```

## ✅ Checklist

- [ ] Icons placed in correct folders
- [ ] Files named exactly as specified
- [ ] Proper sizes (base, @2x, @3x)
- [ ] PNG format with transparency
- [ ] Integration script run successfully
- [ ] Icons display correctly in app
- [ ] No "unassigned child" warnings

---

**Need Help?** Check the `IMAGE_PROMPTS.md` file for detailed creation prompts for each icon type.
