import SwiftUI

@main
struct timelyApp: App {
    var body: some Scene {
        MenuBarExtra("timely", systemImage: "characters.uppercase"
        ) {
            ContentView()
                .frame(width: 500, height: 200)
        }
        .menuBarExtraStyle(.window)
    }
}
