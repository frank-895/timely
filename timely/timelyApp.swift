import SwiftUI

@main
struct timelyApp: App {
    var body: some Scene {
        MenuBarExtra("timely", systemImage: "characters.uppercase"
        ) {
            ContentView()
                .frame(width: 500)
                .fixedSize(horizontal: false, vertical: true)
        }
        .menuBarExtraStyle(.window)
    }
}
