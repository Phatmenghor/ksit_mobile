# Clean everything first (from project root)
echo "🧹 Cleaning Flutter project..."
flutter clean

echo "🧹 Cleaning Android project..."
cd android
./gradlew clean
cd ..

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo "🍎 Installing iOS pods..."
cd ios
pod install
cd ..

echo "🤖 Building Android APK release..."
flutter build apk --release && echo "📱 Copying APK to Desktop..." && cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/ksit-mobile-release.apk

echo "🍎 Building iOS release configuration..."
flutter build ios --config-only --release

echo "✅ Build process completed!"