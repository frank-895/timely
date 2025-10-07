# timely ⏰

A sleek macOS menu bar app for quick timezone conversions between cities around the world.

## Features ✨

- 🌍 **Global Coverage** - Search from thousands of cities worldwide
- ⚡ **Real-time Conversion** - Instant timezone calculations as you type
- 🎯 **Smart Search** - Intelligent city name autocomplete with scrollable results
- 📅 **Date Picker** - Custom calendar for accurate DST calculations on any date
- 🕐 **Smart Date Handling** - Automatically adjusts dates when times cross midnight
- ⏰ **Current Time Button** - Instantly set to your current local time
- 📝 **Flexible Input** - Accepts various time formats (9:30, 09:30, 930)
- 🔄 **Swap Locations** - Quick button to reverse source and destination
- 🎨 **Modern Design** - Clean, rounded interface with smooth interactions
- 🪟 **Menu Bar App** - Lives in your menu bar for quick access

## Usage 🚀

### Basic Time Conversion
1. Enter a time in the left field (HH:mm format)
2. Search and select your source city
3. Search and select your destination city
4. See the converted time instantly on the right

### Advanced Features
- **Date Selection**: Click the calendar icon to choose a specific date (important for DST accuracy)
- **Current Time**: Click the clock icon to instantly set the current time
- **Location Swap**: Click the swap arrows between cities to reverse the conversion
- **Quick Quit**: Click the X in the top right to close the app

### Smart Input
- Type "1" then "0" for 10:00 (won't auto-complete to 01:00)
- Backspace freely in minutes without fighting auto-fill
- Fields always show valid time values

## Requirements 📋

- macOS 14.0+
- Swift 5.9+

## Installation 💻

1. Go to the [Releases](https://github.com/frank-895/timely/releases) page.
2. Download the `.zip` file for the latest version.
3. Unzip the file and drag `timely.app` into your Applications folder.
4. Launch timely!

## Creating a new release (for developers) 🔄

1. Increment the `CFBundleVersion` in Xcode (`Info.plist`) — e.g., `1.1`.
2. Archive the app: `Product → Archive`.
3. Export the `.app` bundle and compress it into a `.zip` file.
4. Go to your GitHub repo → **Releases → Draft a new release**.
   - Tag version: `v1.1`
   - Release title: `v1.1`
   - Upload the `.zip` file.

## License 📄

MIT License - see [LICENSE](LICENSE) file for details.
