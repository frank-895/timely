import Foundation
import ServiceManagement

#if os(macOS)
final class LaunchAtLoginManager {
    static let shared = LaunchAtLoginManager()
    private init() {}

    var isEnabled: Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        } else {
            return false
        }
    }

    func setEnabled(_ enabled: Bool) {
        guard #available(macOS 13.0, *) else { return }
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            #if DEBUG
            print("LaunchAtLoginManager error: \(error)")
            #endif
        }
    }
}
#endif
