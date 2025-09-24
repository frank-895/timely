import Foundation

/// Represents a city/location with a timezone.
struct Location: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var country: String
    var nameLowercased: String
    var timezoneIdentifier: String
}
