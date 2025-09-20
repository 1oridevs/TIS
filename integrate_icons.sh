#!/bin/bash

# TIS App - Icon Integration Script
# This script automatically copies and organizes icons into the Assets.xcassets structure

echo "🎨 TIS App - Icon Integration Script"
echo "====================================="

# Check if icons folder exists
if [ ! -d "icons" ]; then
    echo "❌ Icons folder not found!"
    echo "Please create the icons folder and place your icons according to the structure in ICON_INTEGRATION_GUIDE.md"
    exit 1
fi

echo "✅ Icons folder found"

# Function to copy icons to imageset
copy_to_imageset() {
    local source_dir=$1
    local target_imageset=$2
    local base_name=$3
    
    if [ -d "$source_dir" ]; then
        echo "📁 Processing $source_dir..."
        
        # Create target directory if it doesn't exist
        mkdir -p "TIS/Assets.xcassets/$target_imageset.imageset"
        
        # Copy base image (1x)
        if [ -f "$source_dir/${base_name}.png" ]; then
            cp "$source_dir/${base_name}.png" "TIS/Assets.xcassets/$target_imageset.imageset/"
            echo "  ✅ Copied ${base_name}.png (1x)"
        else
            echo "  ⚠️  ${base_name}.png not found in $source_dir"
        fi
        
        # Copy @2x image
        if [ -f "$source_dir/${base_name}@2x.png" ]; then
            cp "$source_dir/${base_name}@2x.png" "TIS/Assets.xcassets/$target_imageset.imageset/"
            echo "  ✅ Copied ${base_name}@2x.png (2x)"
        fi
        
        # Copy @3x image
        if [ -f "$source_dir/${base_name}@3x.png" ]; then
            cp "$source_dir/${base_name}@3x.png" "TIS/Assets.xcassets/$target_imageset.imageset/"
            echo "  ✅ Copied ${base_name}@3x.png (3x)"
        fi
    else
        echo "⚠️  $source_dir not found, skipping..."
    fi
}

# Function to copy multiple icons to imageset
copy_multiple_to_imageset() {
    local source_dir=$1
    local target_imageset=$2
    local icon_names=("${@:3}")
    
    if [ -d "$source_dir" ]; then
        echo "📁 Processing $source_dir..."
        
        # Create target directory if it doesn't exist
        mkdir -p "TIS/Assets.xcassets/$target_imageset.imageset"
        
        for icon_name in "${icon_names[@]}"; do
            if [ -f "$source_dir/${icon_name}.png" ]; then
                cp "$source_dir/${icon_name}.png" "TIS/Assets.xcassets/$target_imageset.imageset/"
                echo "  ✅ Copied ${icon_name}.png"
            else
                echo "  ⚠️  ${icon_name}.png not found in $source_dir"
            fi
        done
    else
        echo "⚠️  $source_dir not found, skipping..."
    fi
}

# Process App Icon
echo ""
echo "📱 Processing App Icon..."
if [ -d "icons/app-icon" ]; then
    # Copy all app icon sizes
    cp icons/app-icon/*.png TIS/Assets.xcassets/AppIcon.appiconset/ 2>/dev/null
    echo "✅ App icon files copied"
else
    echo "⚠️  App icon folder not found"
fi

# Process Shift Type Icons
echo ""
echo "⏰ Processing Shift Type Icons..."
shift_icons=("regular-shift" "overtime-shift" "special-event-shift" "flexible-shift")
copy_multiple_to_imageset "icons/shift-types" "ShiftTypeIcons" "${shift_icons[@]}"

# Process Feature Icons
echo ""
echo "🎯 Processing Feature Icons..."
feature_icons=("time-tracking" "job-management" "analytics" "history" "settings")
copy_multiple_to_imageset "icons/feature-icons" "FeatureIcons" "${feature_icons[@]}"

# Process Achievement Badges
echo ""
echo "🏆 Processing Achievement Badges..."
badge_icons=("first-shift-badge" "10-hours-badge" "week-complete-badge" "month-complete-badge" "overtime-badge")
copy_multiple_to_imageset "icons/achievement-badges" "AchievementBadges" "${badge_icons[@]}"

# Process Background Patterns
echo ""
echo "🎨 Processing Background Patterns..."
pattern_icons=("geometric-pattern" "dots-pattern" "lines-pattern")
copy_multiple_to_imageset "icons/background-patterns" "BackgroundPatterns" "${pattern_icons[@]}"

# Process Onboarding Illustrations
echo ""
echo "📚 Processing Onboarding Illustrations..."
illustration_icons=("welcome-illustration" "add-job-illustration" "start-tracking-illustration" "view-history-illustration" "analytics-illustration")
copy_multiple_to_imageset "icons/onboarding-illustrations" "OnboardingIllustrations" "${illustration_icons[@]}"

echo ""
echo "🎉 Icon integration complete!"
echo ""
echo "Next steps:"
echo "1. Open Xcode and check Assets.xcassets"
echo "2. Verify all imagesets have the correct files"
echo "3. Test the app to ensure icons display properly"
echo "4. Check for any 'unassigned child' warnings"
echo ""
echo "If you see any warnings, check the ICON_INTEGRATION_GUIDE.md for troubleshooting tips."
