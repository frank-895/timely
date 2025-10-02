import SwiftUI

@main
struct HelperApp: App {
    init() {
        launchMainApp()
    }
    
    var body: some Scene {
        // No windows needed for a background helper app
        Settings {
            EmptyView()
        }
    }
    
    private func launchMainApp() {
        // Replace "com.yourcompany.timely" with your main app's bundle identifier
        let mainAppBundleID = "com.yourcompany.timely"
        
        // Attempt to get the main app's URL and launch it
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: mainAppBundleID) {
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        }
        
        // Quit the helper immediately after launching the main app
        DispatchQueue.main.async {
            NSApp.terminate(nil)
        }
    }
}
