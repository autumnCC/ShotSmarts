# ShotSmarts / 光影指南

ShotSmarts (光影指南) is an iOS app that helps photographers of all levels calculate the optimal camera settings for any shooting scenario. The app provides recommendations for aperture, shutter speed, metering mode, and exposure compensation based on light conditions, ISO settings, and scene mode.

## Features

- Light condition selection (Sunny, Cloudy, Overcast, Night, Indoor)
- ISO adjustment slider (100-3200)
- Scene mode selection (Sports, Portrait, Landscape, Macro, Night)
- Dynamic calculation of recommended aperture and shutter speed
- Automatic metering mode matching
- Intelligent exposure compensation suggestions
- Parameter history with saving and management features
- Multi-language support (English, Chinese, Japanese)

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Building the Project

1. Clone or download the repository
2. Open `ShotSmarts.xcodeproj` in Xcode
3. Select your development team in the Signing & Capabilities tab
4. Build and run the app on a simulator or device

## Project Structure

- `Models/` - Contains data models and calculation algorithms
- `Views/` - Contains all SwiftUI views
- `Localizations/` - Contains localization files for different languages

## Submitting to the App Store

### 1. Prepare Your App

1. Verify all app functionality works correctly
2. Ensure all text is properly localized
3. Test the app on multiple device sizes
4. Create app icons and splash screens if not already included

### 2. App Store Connect Setup

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Create a new app listing:
   - Select "My Apps" and click "+"
   - Choose "New App"
   - Select iOS as the platform
   - Enter app information:
     - For Chinese markets: Use "光影指南" as the name
     - For other markets: Use "ShotSmarts" as the name
   - Select your primary language
   - Use the bundle ID from your Xcode project
   - Enter an SKU (a unique identifier for your app)

3. Complete App Information:
   - Add app description
   - Add keywords
   - Add support URL
   - Add marketing URL (optional)
   - Enter privacy policy URL
   - Set app category (likely "Photo & Video")

4. Add screenshots for all required device sizes:
   - iPhone (6.5" Display)
   - iPhone (5.5" Display)
   - iPad Pro (12.9" Display, 3rd Generation)
   - iPad Pro (12.9" Display, 2nd Generation)

5. Upload app preview videos (optional)
6. Set app pricing and availability
7. Set up in-app purchases if applicable
8. Complete app review information

### 3. Upload Your Build

1. In Xcode, select "Generic iOS Device" as the build destination
2. Go to Product > Archive
3. When archiving completes, the Organizer window will appear
4. Select your archive and click "Distribute App"
5. Select "App Store Connect" and click "Next"
6. Select "Upload" and click "Next"
7. Select options for distribution and click "Next"
8. Review the settings and click "Upload"

### 4. Submit for Review

1. Back in App Store Connect, select your app
2. Click on "iOS App" under the "App Store" tab
3. Select the build you just uploaded
4. Complete the "App Review Information" section
5. Complete the "Version Information" section
6. Click "Save" and then "Submit for Review"

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Created by [Your Name] - Contact: [Your Email] 