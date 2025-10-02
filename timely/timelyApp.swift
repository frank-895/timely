import SwiftUI
import Sparkle

@main
struct timelyApp: App {
    // Sparkle updater controller
    let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .frame(width: 500)
                .fixedSize(horizontal: false, vertical: true)
        } label: {
            // Use NSImage if available, else system clock
            Image(nsImage: NSImage(named: "MenuIcon") ?? NSImage(systemSymbolName: "clock", accessibilityDescription: nil)!)
                .resizable()
                .frame(width: 16, height: 16)
        }
        .menuBarExtraStyle(.window)
    }
}
