import SwiftUI

@main
struct timelyApp: App {
    var body: some Scene {
        MenuBarExtra {
            // Popover content
            ContentView()
                .frame(width: 500)
                .fixedSize(horizontal: false, vertical: true)
        } label: {
            if let menuIcon = NSImage(named: "MenuIcon") {
                // Set the proper size on the NSImage itself
                menuIcon.size = NSSize(width: 16, height: 16)
                return Image(nsImage: menuIcon)
            } else {
                return Image(systemName: "clock")
            }
        }
        .menuBarExtraStyle(.window)
    }
}
