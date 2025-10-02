// Cross-platform fallback for LaunchAtLoginManager so non-macOS targets compile.
// If you already include a macOS-specific implementation, this file will provide
// a no-op stub for other platforms where login items are not applicable.

import Foundation

#if !os(macOS)
final class LaunchAtLoginManager {
    static let shared = LaunchAtLoginManager()
    private init() {}

    var isEnabled: Bool { false }

    func setEnabled(_ enabled: Bool) {
        // No-op on non-macOS platforms
    }
}
#endif
