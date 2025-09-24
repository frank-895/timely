import Foundation
import SwiftUI
import Combine

/// ViewModel that holds the available locations and the two currently selected indices.
/// We use index-based selection because it's simple and avoids tag/hash pitfalls
/// while you're getting comfortable with Pickers.
@MainActor
class TimeConverterViewModel: ObservableObject {
    // MARK: - Published state
    
    /// The list of available locations the user can pick from.
    @Published var availableLocations: [Location]
    
    /// Selected indices (for picker bindings)
    @Published var selectedIndex1: Int
    @Published var selectedIndex2: Int
    
    // MARK: - Convenience accessors
    
    /// Convenience computed property for the first selected location.
    var selectedLocation1: Location {
        // safe-guard: return first if index gets out of range
        if availableLocations.indices.contains(selectedIndex1) {
            return availableLocations[selectedIndex1]
        } else {
            return availableLocations.first ?? Location(name: "Unknown")
        }
    }
    
    /// Convenience computed property for the second selected location.
    var selectedLocation2: Location {
        if availableLocations.indices.contains(selectedIndex2) {
            return availableLocations[selectedIndex2]
        } else {
            return availableLocations.first ?? Location(name: "Unknown")
        }
    }
    
    // MARK: - Init
    
    /// Initialize with an optional custom list (useful for tests).
    init(locations: [Location]? = nil) {
        // Step 1: compute locations locally
        var locs = locations ?? [
            Location(name: "New York"),
            Location(name: "London"),
            Location(name: "Tokyo"),
            Location(name: "Sydney")
        ]
        
        // Step 2: ensure at least one location
        if locs.isEmpty {
            locs = [Location(name: "Placeholder")]
        }
        
        // Step 3: assign all stored properties
        self.availableLocations = locs
        
        if locs.count >= 2 {
            self.selectedIndex1 = 0
            self.selectedIndex2 = 1
        } else {
            self.selectedIndex1 = 0
            self.selectedIndex2 = 0
        }
    }
}
