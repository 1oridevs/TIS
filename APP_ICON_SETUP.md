# TIS App Icon Setup Guide

## Overview
This guide explains how to set up the app icons for the TIS (Time is Money) iOS application.

## Required Icon Sizes
The app requires the following icon sizes:

### iPhone Icons
- 20x20 (2x, 3x) - 40x40, 60x60
- 29x29 (2x, 3x) - 58x58, 87x87  
- 40x40 (2x, 3x) - 80x80, 120x120
- 60x60 (2x, 3x) - 120x120, 180x180

### iPad Icons
- 20x20 (1x, 2x) - 20x20, 40x40
- 29x29 (1x, 2x) - 29x29, 58x58
- 40x40 (1x, 2x) - 40x40, 80x80
- 76x76 (1x, 2x) - 76x76, 152x152
- 83.5x83.5 (2x) - 167x167

### App Store
- 1024x1024 (iOS Marketing)

## Design Guidelines

### Color Scheme
- Primary: Blue (#0064C8)
- Secondary: White (#FFFFFF)
- Accent: Light Blue (#4A90E2)

### Icon Design
The TIS app icon should feature:
- A clock/time element to represent time tracking
- Money/currency symbols to represent earnings
- Clean, modern design that works at all sizes
- High contrast for visibility on various backgrounds

### Design Elements
1. **Clock Face**: Central clock with hands showing time
2. **Money Symbol**: Dollar sign or currency symbol
3. **Background**: Solid color or subtle gradient
4. **Typography**: Clean, readable text if needed

## Implementation

### Using the Python Script
1. Install Pillow: `pip install Pillow`
2. Run the generator: `python3 generate_app_icons.py`
3. The script will create all required icon sizes

### Manual Creation
1. Create a 1024x1024 master icon
2. Use image editing software to resize for each required size
3. Save each icon with the correct filename in the AppIcon.appiconset folder

## File Structure
```
TIS/Assets.xcassets/AppIcon.appiconset/
├── Contents.json
├── appicon-20.png
├── appicon-29.png
├── appicon-40.png
├── appicon-58.png
├── appicon-60.png
├── appicon-76.png
├── appicon-80.png
├── appicon-87.png
├── appicon-120.png
├── appicon-152.png
├── appicon-167.png
├── appicon-180.png
└── appicon-1024.png
```

## Testing
After adding the icons:
1. Build the project in Xcode
2. Check that all icon sizes are properly recognized
3. Test on both iPhone and iPad simulators
4. Verify icons appear correctly in the app switcher and home screen

## Notes
- All icons must be PNG format
- Icons should not have transparency for best results
- Consider creating icons for both light and dark mode if needed
- Test icons on various device backgrounds to ensure visibility
