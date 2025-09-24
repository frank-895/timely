import Foundation

/// Represents a location with a human-friendly name.
/// We keep it small for now (we'll add timezone/coordinates later).
struct Location: Identifiable, Hashable, Codable {
    /// Unique identifier for SwiftUI/ForEach
    var id = UUID()
    
    /// Display name for the location (e.g. "New York")
    var name: String
}
