# App Icon Replacement Instructions

This document provides step-by-step instructions on how to replace the default Flutter logo with your custom app logo (NSLOGO1.png) for both Android and iOS platforms.

## Prerequisites

1. Your custom logo file: `assets/images/NSLOGO1.png`
2. Image editing software (e.g., Photoshop, GIMP, or online tools)
3. Icon generation tool (recommended)

## Android Icon Replacement

### Method 1: Manual Replacement (Recommended)

1. Generate different size versions of your logo:
   - mipmap-mdpi: 48x48 pixels
   - mipmap-hdpi: 72x72 pixels
   - mipmap-xhdpi: 96x96 pixels
   - mipmap-xxhdpi: 144x144 pixels
   - mipmap-xxxhdpi: 192x192 pixels

2. Replace the existing ic_launcher.png files:
   - Replace `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` with 48x48 version
   - Replace `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` with 72x72 version
   - Replace `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` with 96x96 version
   - Replace `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` with 144x144 version
   - Replace `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` with 192x192 version

### Method 2: Using Flutter Launcher Icons Package (Easiest)

1. Add the flutter_launcher_icons dependency to your `pubspec.yaml`:
   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.13.1
   ```

2. Create a configuration in your `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/images/NSLOGO1.png"
     adaptive_icon_background: "#FFFFFF" # Optional, for Android 8.0+
   ```

3. Run the package:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons:main
   ```

## iOS Icon Replacement

### Method 1: Manual Replacement

1. Generate different size versions of your logo:
   - Icon-App-20x20@1x.png: 20x20 pixels
   - Icon-App-20x20@2x.png: 40x40 pixels
   - Icon-App-20x20@3x.png: 60x60 pixels
   - Icon-App-29x29@1x.png: 29x29 pixels
   - Icon-App-29x29@2x.png: 58x58 pixels
   - Icon-App-29x29@3x.png: 87x87 pixels
   - Icon-App-40x40@1x.png: 40x40 pixels
   - Icon-App-40x40@2x.png: 80x80 pixels
   - Icon-App-40x40@3x.png: 120x120 pixels
   - Icon-App-60x60@2x.png: 120x120 pixels
   - Icon-App-60x60@3x.png: 180x180 pixels
   - Icon-App-76x76@1x.png: 76x76 pixels
   - Icon-App-76x76@2x.png: 152x152 pixels
   - Icon-App-83.5x83.5@2x.png: 167x167 pixels
   - Icon-App-1024x1024@1x.png: 1024x1024 pixels

2. Replace each file in `ios/Runner/Assets.xcassets/AppIcon.appiconset/` with the corresponding size version.

### Method 2: Using Online Tools

1. Use an online icon generator like [appicon.co](https://appicon.co) or [makeappicon.com](https://makeappicon.com)
2. Upload your NSLOGO1.png file
3. Download the generated icon set
4. Replace the contents of `ios/Runner/Assets.xcassets/AppIcon.appiconset/` with the generated files

## Testing Your Changes

### For Android:
```bash
flutter clean
flutter pub get
flutter run
```

### For iOS:
```bash
flutter clean
flutter pub get
open ios/Runner.xcworkspace
# Build and run in Xcode
```

## Additional Notes

1. Make sure your logo has a 1:1 aspect ratio (square)
2. For the best results, use a high-resolution version of your logo (at least 1024x1024 pixels)
3. Consider having a version with a background color if your logo has transparency
4. Test on different devices to ensure the icons display correctly

## Troubleshooting

1. If icons don't update:
   - Clean the build: `flutter clean`
   - Delete the build folder manually
   - Run `flutter pub get`
   - Rebuild the app

2. If you see the old icon on your device:
   - Uninstall the app completely
   - Restart your device
   - Reinstall the app

3. For iOS issues:
   - Open the project in Xcode
   - Clean the build folder (Cmd+Shift+K)
   - Build and run from Xcode