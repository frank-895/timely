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
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text(" timely")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
