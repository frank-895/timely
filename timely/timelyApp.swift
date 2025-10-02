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

    // Track whether the menu bar extra is inserted
    @State private var isMenuBarExtraInserted = true

    var body: some Scene {
        MenuBarExtra(isInserted: $isMenuBarExtraInserted) {
            ContentView()
                .frame(width: 500)
                .fixedSize(horizontal: false, vertical: true)
        } label: {
            Image("MenuIcon")
                .renderingMode(.template)     // let macOS tint + size it
                .imageScale(.small)           // force proper menu bar scale
                .font(.system(size: 14))      // an extra clamp (optional)
        }
        .menuBarExtraStyle(.window)

    }
}
