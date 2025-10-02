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
- Sparkle handles all future updates automatically for apps installed via GitHub Releases.

## Installation 💻

timely is designed to be easy to install and update without the App Store.

1. Go to the [Releases](https://github.com/yourusername/timely/releases) page.  
2. Download the `.zip` file for the latest version.  
3. Unzip the file and drag `timely.app` into your Applications folder.  
4. Launch timely — Sparkle will automatically check for future updates and notify you when a new version is available.  

> Users can keep timely updated effortlessly without needing the App Store.

## Creating a new release (for developers) 🔄

1. Increment the `CFBundleVersion` in Xcode (`Info.plist`) — e.g., `1.1`.  
2. Archive the app: `Product → Archive`.  
3. Export the `.app` bundle and compress it into a `.zip` file.  
4. Go to your GitHub repo → **Releases → Draft a new release**.  
   - Tag version: `v1.1`  
   - Release title: `v1.1`  
   - Upload the `.zip` file.  
5. Update `appcast.xml` in the repository:  
   ```xml
   <item>
     <title>v1.1</title>
     <sparkle:releaseNotesLink>https://github.com/yourusername/timely/releases/tag/v1.1</sparkle:releaseNotesLink>
     <enclosure url="https://github.com/yourusername/timely/releases/download/v1.1/timely.zip"
                sparkle:version="1.1"
                type="application/octet-stream"/>
   </item>
```
6. Commit and push the updated appcast.xml to the main branch.

Once this is done, **users running timely will automatically see and be able to install the new version**.

### Notes
- Sparkle does not require the App Store. Users can install and update directly from GitHub.
- Make sure the `appcast.xml` file is always accessible via the **raw GitHub URL**.

## License 📄

MIT License - see [LICENSE](LICENSE) file for details.
