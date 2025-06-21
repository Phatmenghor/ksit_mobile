#!/bin/bash

echo "🧹 Cleaning Flutter project completely..."

# Step 1: Clean flutter build
flutter clean

# Step 2: Delete additional cache & build artifacts
rm -rf .dart_tool/ .packages pubspec.lock
rm -rf build/ android/.gradle android/build android/app/build
rm -rf ios/Pods ios/.symlinks ios/build ios/Flutter/Flutter.framework ios/Flutter/App.framework ios/Flutter/engine
rm -rf macos/build macos/Flutter/ephemeral
rm -rf windows/build linux/build web/build

echo "📦 Getting Flutter packages..."
flutter pub get

echo "🔧 Running platform setups..."
flutter pub run build_runner build --delete-conflicting-outputs

# Step 3: Rebuild iOS and Android native stuff
echo "🔄 iOS pod install..."
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..

# Step 4: Patch Flutter iOS configs to include CocoaPods settings and avoid warnings
echo '#include? "../Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"' >> ios/Flutter/Debug.xcconfig
echo '#include? "../Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"' >> ios/Flutter/Release.xcconfig

echo "✅ All done! Your project is clean and reinstalled."
