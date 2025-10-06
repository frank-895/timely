import SwiftUI

@main
struct timelyApp: App {
    // Track whether the menu bar extra is inserted
    @State private var isMenuBarExtraInserted = true

    var body: some Scene {
        MenuBarExtra(isInserted: $isMenuBarExtraInserted) {
            ContentView()
                .frame(width: 500)
                .fixedSize(horizontal: false, vertical: true)
        } label: {
            Image("MenuIcon")
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
        }
    }
}
