import SwiftUI
import Combine

@MainActor
class TimeConverterViewModel: ObservableObject {
    @Published var allLocations: [Location] = []

    @Published var selectedLocation1: Location?
    @Published var selectedLocation2: Location?

    @Published var filteredLocations1: [Location] = []
    @Published var filteredLocations2: [Location] = []

    // Input validation manager
    let validationManager = InputValidationManager()
    
    // Input states for validation
    lazy var location1Input: InputFieldState = {
        validationManager.registerInput(
            id: "location1", 
            defaultValue: "",
            validationRule: { [weak self] value in
                // Location validation: must match an existing location (empty is NOT valid)
                guard !value.isEmpty else { return false }
                
                // Check if the value matches any location in our list
                guard let self = self else { return false }
                return self.allLocations.contains { location in
                    "\(location.name), \(location.country)" == value
                }
            }
        )
    }()
    
    lazy var location2Input: InputFieldState = {
        validationManager.registerInput(
            id: "location2", 
            defaultValue: "",
            validationRule: { [weak self] value in
                // Location validation: must match an existing location (empty is NOT valid)
                guard !value.isEmpty else { return false }
                
                // Check if the value matches any location in our list
                guard let self = self else { return false }
                return self.allLocations.contains { location in
                    "\(location.name), \(location.country)" == value
                }
            }
        )
    }()

    private var cancellables = Set<AnyCancellable>()
    private let maxResults = 10

    init() {
        loadCities()
        setupValidationBindings()
        setupFiltering()
    }

    private func loadCities() {
        guard let url = Bundle.main.url(forResource: "cities", withExtension: "json") else {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let rawCities = try JSONDecoder().decode([RawCity].self, from: data)
            
            let locations = rawCities.compactMap { city -> Location? in
                guard let tz = city.timezone else { return nil }
                return Location(
                    name: city.city_ascii,
                    country: city.country,
                    nameLowercased: city.city_ascii.lowercased(),
                    timezoneIdentifier: tz
                )
            }

            self.allLocations = locations
            
            // Set default locations by directly setting the input state values
            if let defaultLocation1 = locations.first(where: { $0.name.lowercased().contains("new york") }) ?? locations.first {
                self.selectedLocation1 = defaultLocation1
                let defaultText1 = "\(defaultLocation1.name), \(defaultLocation1.country)"
                
                // Set the default value directly on the input state
                _ = self.location1Input
                self.location1Input.currentValue = defaultText1
                self.location1Input.lastValid = defaultText1
                self.location1Input.markValidated()
            }
            
            if let defaultLocation2 = locations.first(where: { $0.name.lowercased().contains("london") }) ?? locations.dropFirst().first {
                self.selectedLocation2 = defaultLocation2
                let defaultText2 = "\(defaultLocation2.name), \(defaultLocation2.country)"
                
                // Set the default value directly on the input state
                _ = self.location2Input
                self.location2Input.currentValue = defaultText2
                self.location2Input.lastValid = defaultText2
                self.location2Input.markValidated()
            }

        } catch {
            // Failed to load cities - will use empty array
        }
    }

    private func setupValidationBindings() {
        // Bind location1Input currentValue changes to filtering
        location1Input.$currentValue
            .sink { _ in
                // This will trigger filtering through setupFiltering
            }
            .store(in: &cancellables)
            
        // Bind location2Input currentValue changes to filtering  
        location2Input.$currentValue
            .sink { _ in
                // This will trigger filtering through setupFiltering
            }
            .store(in: &cancellables)
    }

    private func setupFiltering() {
        // Picker 1
        location1Input.$currentValue
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .map { [weak self] query in
                guard let self = self else { return [] }
                guard !query.isEmpty else { return [] }
                
                // Don't show suggestions if it's already a valid selection
                if let selectedLocation = self.selectedLocation1,
                   query == "\(selectedLocation.name), \(selectedLocation.country)" {
                    return []
                }
                
                return self.allLocations
                    .filter { $0.nameLowercased.contains(query.lowercased()) }
                    .prefix(self.maxResults)
                    .map { $0 }
            }
            .assign(to: \.filteredLocations1, on: self)
            .store(in: &cancellables)

        // Picker 2
        location2Input.$currentValue
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .map { [weak self] query in
                guard let self = self else { return [] }
                guard !query.isEmpty else { return [] }
                
                // Don't show suggestions if it's already a valid selection
                if let selectedLocation = self.selectedLocation2,
                   query == "\(selectedLocation.name), \(selectedLocation.country)" {
                    return []
                }
                
                return self.allLocations
                    .filter { $0.nameLowercased.contains(query.lowercased()) }
                    .prefix(self.maxResults)
                    .map { $0 }
            }
            .assign(to: \.filteredLocations2, on: self)
            .store(in: &cancellables)
    }
}

private struct RawCity: Codable {
    let city: String
    let city_ascii: String
    let country: String
    let timezone: String?
}
