// Utility to apply the custom app icon or status item icon.
// For macOS: sets Dock icon to the asset named "MenuIcon" if present.
// If you are using a status bar app, you can also use the same asset for the status item.

import Foundation

#if os(macOS)
import AppKit

enum AppIconHelper {
    static func applyDockIconIfAvailable() {
        if let image = NSImage(named: "MenuIcon") {
            NSApplication.shared.applicationIconImage = image
        }
    }

    static func statusItemImage() -> NSImage? {
        return NSImage(named: "MenuIcon")
    }
}
#endif

#if canImport(UIKit)
import UIKit

enum AppIconHelper {
    static func applyAlternateIconIfAvailable() {
        // iOS only supports changing the app icon via alternate icons configured in Info.plist.
        // This helper attempts to set an alternate icon named "MenuIcon" if configured.
        guard UIApplication.shared.supportsAlternateIcons else { return }
        Task { @MainActor in
            do {
                try await UIApplication.shared.setAlternateIconName("MenuIcon")
            } catch {
                #if DEBUG
                print("Failed to set alternate icon to 'MenuIcon': \(error)")
                #endif
            }
        }
    }
}
#endif
