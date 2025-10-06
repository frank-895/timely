# timely ⏰

A sleek macOS menu bar app for quick timezone conversions between cities around the world.

## Features ✨

- 🌍 **Global Coverage** - Search from thousands of cities worldwide
- ⚡ **Real-time Conversion** - Instant timezone calculations as you type
- 🎯 **Smart Search** - Intelligent city name autocomplete
- 🕐 **Current Date** - Uses today's date for accurate daylight saving time
- 📝 **Flexible Input** - Accepts various time formats (9:30, 09:30, 930)
- 🎨 **Clean Design** - Native macOS look and feel

## Usage 🚀

1. Enter a time in the left field
2. Search and select your source city
3. Search and select your destination city
4. See the converted time instantly on the right

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
