#!/bin/bash

echo "🚀 TIS - Time is Money iOS App Setup"
echo "====================================="
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed or not in PATH"
    echo "Please install Xcode from the App Store and try again"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "TIS.xcodeproj/project.pbxproj" ]; then
    echo "❌ TIS.xcodeproj not found. Please run this script from the project root directory"
    exit 1
fi

echo "✅ Project structure looks good!"
echo ""

# List all Swift files to verify they exist
echo "📁 Project files:"
find TIS -name "*.swift" | sort
echo ""

# Check Core Data model
if [ -f "TIS/TISModel.xcdatamodeld/TISModel.xcdatamodel/contents" ]; then
    echo "✅ Core Data model found"
else
    echo "❌ Core Data model missing"
fi

# Check Assets
if [ -d "TIS/Assets.xcassets" ]; then
    echo "✅ Assets catalog found"
else
    echo "❌ Assets catalog missing"
fi

echo ""
echo "🎯 Next Steps:"
echo "1. Open TIS.xcodeproj in Xcode"
echo "2. Select your target device or simulator"
echo "3. Press Cmd+R to build and run"
echo ""
echo "📱 Features included:"
echo "• Time tracking with start/stop functionality"
echo "• Job management with hourly rates"
echo "• Bonus system for special events"
echo "• History tracking and filtering"
echo "• Modern SwiftUI interface"
echo "• Offline-first Core Data storage"
echo ""
echo "Happy coding! 💰⏰"
