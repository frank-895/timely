import SwiftUI
import Combine

@MainActor
class TimeConverterViewModel: ObservableObject {
    @Published var allLocations: [Location] = []

    @Published var selectedLocation1: Location?
    @Published var selectedLocation2: Location?

    @Published var filteredLocations1: [Location] = []
    @Published var filteredLocations2: [Location] = []

    @Published var convertedTime: String = "--:--"
    @Published var selectedDate: Date = Date()
    @Published var convertedDate: Date = Date()
    @Published var convertedTimeZone: TimeZone = TimeZone.current

    // Input validation manager
    let validationManager = InputValidationManager()
    
    // Input states for validation
    lazy var timeInput: InputFieldState = {
        // Get current time as default
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: Date())

        return validationManager.registerInput(
            id: "time",
            defaultValue: currentTime,
            validationRule: { value in
                // Time validation: must be in HH:mm format (24-hour)
                return TimeConverter.isValidTimeFormat(value)
            }
        )
    }()
    
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

    // UserDefaults keys for persistence
    private let location1NameKey = "savedLocation1Name"
    private let location1CountryKey = "savedLocation1Country"
    private let location2NameKey = "savedLocation2Name"
    private let location2CountryKey = "savedLocation2Country"

    init() {
        loadCities()
        setupValidationBindings()
        setupFiltering()
        setupTimeConversion()
        setupLocationPersistence()
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

            // Try to load saved locations first
            let (savedLocation1, savedLocation2) = loadSavedLocations()

            // Location 1: use saved if available, otherwise default to New York
            let location1 = savedLocation1 ?? locations.first(where: { $0.name.lowercased().contains("new york") }) ?? locations.first
            if let location1 = location1 {
                self.selectedLocation1 = location1
                let text1 = "\(location1.name), \(location1.country)"

                // Set the value directly on the input state with async dispatch
                _ = self.location1Input
                DispatchQueue.main.async {
                    self.location1Input.currentValue = text1
                    self.location1Input.lastValid = text1
                    self.location1Input.needsValidation = false
                }
            }

            // Location 2: use saved if available, otherwise default to London
            let location2 = savedLocation2 ?? locations.first(where: { $0.name.lowercased().contains("london") }) ?? locations.dropFirst().first
            if let location2 = location2 {
                self.selectedLocation2 = location2
                let text2 = "\(location2.name), \(location2.country)"

                // Set the value directly on the input state with async dispatch
                _ = self.location2Input
                DispatchQueue.main.async {
                    self.location2Input.currentValue = text2
                    self.location2Input.lastValid = text2
                    self.location2Input.needsValidation = false
                }
            }
            
            // Initialize the time input (will use current time as default)
            _ = self.timeInput

            DispatchQueue.main.async {
                // Trigger initial conversion after setting defaults
                self.updateConvertedTime(
                    timeValue: self.timeInput.currentValue,
                    fromLocation: self.selectedLocation1,
                    toLocation: self.selectedLocation2,
                    date: self.selectedDate
                )
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locations in
                self?.filteredLocations1 = locations
            }
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locations in
                self?.filteredLocations2 = locations
            }
            .store(in: &cancellables)
    }
    
    private func setupTimeConversion() {
        // Combine all the inputs that should trigger conversion
        Publishers.CombineLatest4(
            timeInput.$currentValue,
            $selectedLocation1,
            $selectedLocation2,
            $selectedDate
        )
        .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
        .sink { [weak self] timeValue, location1, location2, date in
            self?.updateConvertedTime(timeValue: timeValue, fromLocation: location1, toLocation: location2, date: date)
        }
        .store(in: &cancellables)
    }
    
    private func updateConvertedTime(timeValue: String, fromLocation: Location?, toLocation: Location?, date: Date) {
        // Reset to default if any required data is missing
        guard let fromLocation = fromLocation,
              let toLocation = toLocation,
              !timeValue.isEmpty,
              TimeConverter.isValidTimeFormat(timeValue) else {
            convertedTime = "--:--"
            convertedDate = date
            convertedTimeZone = TimeZone.current
            return
        }

        // Set the target timezone
        if let targetTimeZone = TimeZone(identifier: toLocation.timezoneIdentifier) {
            convertedTimeZone = targetTimeZone
        }

        // Convert the time using the selected date (important for DST)
        if let result = TimeConverter.convertTimeWithDate(timeValue, from: fromLocation, to: toLocation, on: date) {
            convertedTime = result.time
            convertedDate = result.date
        } else {
            convertedTime = "--:--"
            convertedDate = date
        }
    }

    /// Swaps the two locations
    func swapLocations() {
        // Swap selected locations
        let tempLocation = selectedLocation1
        selectedLocation1 = selectedLocation2
        selectedLocation2 = tempLocation

        // Swap input field values
        let tempInputValue = location1Input.currentValue
        let tempLastValid = location1Input.lastValid

        location1Input.currentValue = location2Input.currentValue
        location1Input.lastValid = location2Input.lastValid

        location2Input.currentValue = tempInputValue
        location2Input.lastValid = tempLastValid

        // Both inputs are valid after swap (they were valid before)
        location1Input.needsValidation = false
        location2Input.needsValidation = false
    }

    /// Sets the time input to the current time
    func setCurrentTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: Date())

        // Clear focus to allow the update to propagate
        timeInput.isFocused = false

        timeInput.currentValue = currentTime
        timeInput.lastValid = currentTime
        timeInput.needsValidation = false
    }

    // MARK: - Location Persistence

    /// Sets up auto-save for location changes
    private func setupLocationPersistence() {
        // Save location 1 whenever it changes
        $selectedLocation1
            .dropFirst() // Skip initial value
            .sink { [weak self] location in
                self?.saveLocation1(location)
            }
            .store(in: &cancellables)

        // Save location 2 whenever it changes
        $selectedLocation2
            .dropFirst() // Skip initial value
            .sink { [weak self] location in
                self?.saveLocation2(location)
            }
            .store(in: &cancellables)
    }

    /// Saves location 1 to UserDefaults
    private func saveLocation1(_ location: Location?) {
        if let location = location {
            UserDefaults.standard.set(location.name, forKey: location1NameKey)
            UserDefaults.standard.set(location.country, forKey: location1CountryKey)
        } else {
            UserDefaults.standard.removeObject(forKey: location1NameKey)
            UserDefaults.standard.removeObject(forKey: location1CountryKey)
        }
    }

    /// Saves location 2 to UserDefaults
    private func saveLocation2(_ location: Location?) {
        if let location = location {
            UserDefaults.standard.set(location.name, forKey: location2NameKey)
            UserDefaults.standard.set(location.country, forKey: location2CountryKey)
        } else {
            UserDefaults.standard.removeObject(forKey: location2NameKey)
            UserDefaults.standard.removeObject(forKey: location2CountryKey)
        }
    }

    /// Loads saved locations from UserDefaults
    private func loadSavedLocations() -> (Location?, Location?) {
        var savedLocation1: Location?
        var savedLocation2: Location?

        if let name1 = UserDefaults.standard.string(forKey: location1NameKey),
           let country1 = UserDefaults.standard.string(forKey: location1CountryKey) {
            savedLocation1 = allLocations.first { $0.name == name1 && $0.country == country1 }
        }

        if let name2 = UserDefaults.standard.string(forKey: location2NameKey),
           let country2 = UserDefaults.standard.string(forKey: location2CountryKey) {
            savedLocation2 = allLocations.first { $0.name == name2 && $0.country == country2 }
        }

        return (savedLocation1, savedLocation2)
    }
}

private struct RawCity: Codable {
    let city: String
    let city_ascii: String
    let country: String
    let timezone: String?
}
