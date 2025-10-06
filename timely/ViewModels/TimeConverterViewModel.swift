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

    // Input validation manager
    let validationManager = InputValidationManager()
    
    // Input states for validation
    lazy var timeInput: InputFieldState = {
        validationManager.registerInput(
            id: "time",
            defaultValue: "12:00",
            validationRule: { value in
                // Time validation: must be in HH:mm format (24-hour)
                return Self.isValidTimeFormat(value)
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

    init() {
        loadCities()
        setupValidationBindings()
        setupFiltering()
        setupTimeConversion()
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
                
                // Set the default value directly on the input state with async dispatch
                _ = self.location1Input
                DispatchQueue.main.async {
                    self.location1Input.currentValue = defaultText1
                    self.location1Input.lastValid = defaultText1
                    self.location1Input.needsValidation = false
                }
            }
            
            if let defaultLocation2 = locations.first(where: { $0.name.lowercased().contains("london") }) ?? locations.dropFirst().first {
                self.selectedLocation2 = defaultLocation2
                let defaultText2 = "\(defaultLocation2.name), \(defaultLocation2.country)"
                
                // Set the default value directly on the input state with async dispatch
                _ = self.location2Input
                DispatchQueue.main.async {
                    self.location2Input.currentValue = defaultText2
                    self.location2Input.lastValid = defaultText2
                    self.location2Input.needsValidation = false
                }
            }
            
            // Initialize the time input with default value
            _ = self.timeInput
            DispatchQueue.main.async {
                self.timeInput.currentValue = "12:00"
                self.timeInput.lastValid = "12:00"
                self.timeInput.needsValidation = false
                
                // Trigger initial conversion after setting defaults
                self.updateConvertedTime(
                    timeValue: "12:00", 
                    fromLocation: self.selectedLocation1, 
                    toLocation: self.selectedLocation2
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
        Publishers.CombineLatest3(
            timeInput.$currentValue,
            $selectedLocation1,
            $selectedLocation2
        )
        .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
        .sink { [weak self] timeValue, location1, location2 in
            self?.updateConvertedTime(timeValue: timeValue, fromLocation: location1, toLocation: location2)
        }
        .store(in: &cancellables)
    }
    
    private func updateConvertedTime(timeValue: String, fromLocation: Location?, toLocation: Location?) {
        // Reset to default if any required data is missing
        guard let fromLocation = fromLocation,
              let toLocation = toLocation,
              !timeValue.isEmpty,
              Self.isValidTimeFormat(timeValue) else {
            convertedTime = "--:--"
            return
        }
        
        // Convert the time
        if let converted = convertTime(timeValue, from: fromLocation, to: toLocation) {
            convertedTime = converted
        } else {
            convertedTime = "--:--"
        }
    }
    
    private func convertTime(_ timeString: String, from fromLocation: Location, to toLocation: Location) -> String? {
        // Normalize the time string
        guard let normalizedTime = Self.normalizeTimeFormat(timeString) else {
            return nil
        }
        
        // Parse the time components
        let components = normalizedTime.split(separator: ":")
        guard components.count == 2,
              let hours = Int(components[0]),
              let minutes = Int(components[1]) else {
            return nil
        }
        
        // Get current date
        let calendar = Calendar.current
        let today = Date()
        
        // Create timezone objects
        guard let fromTimeZone = TimeZone(identifier: fromLocation.timezoneIdentifier),
              let toTimeZone = TimeZone(identifier: toLocation.timezoneIdentifier) else {
            return nil
        }
        
        // Create date components for the time in the source timezone
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: today)
        dateComponents.hour = hours
        dateComponents.minute = minutes
        dateComponents.second = 0
        dateComponents.timeZone = fromTimeZone
        
        // Create the date in the source timezone
        guard let sourceDate = calendar.date(from: dateComponents) else {
            return nil
        }
        
        // Convert to target timezone
        let formatter = DateFormatter()
        formatter.timeZone = toTimeZone
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: sourceDate)
    }
    
    /// Validates time format: accepts formats like "9:30", "09:30", "21:45"
    /// Normalizes to HH:mm format and validates hours (00-23) and minutes (00-59)
    static func isValidTimeFormat(_ timeString: String) -> Bool {
        let trimmed = timeString.trimmingCharacters(in: .whitespaces)
        
        // Must be in H:mm or HH:mm format for validation to pass
        guard let match = trimmed.firstMatch(of: /^(\d{1,2}):(\d{2})$/) else {
            return false
        }
        
        let hours = Int(match.1) ?? -1
        let minutes = Int(match.2) ?? -1
        
        // Validate ranges
        return hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59
    }
    
    /// Normalizes time string to HH:mm format (e.g., "9:30" -> "09:30")
    /// Only accepts complete, valid time formats for normalization
    static func normalizeTimeFormat(_ timeString: String) -> String? {
        let trimmed = timeString.trimmingCharacters(in: .whitespaces)
        
        // Full format: H:mm or HH:mm
        if let match = trimmed.firstMatch(of: /^(\d{1,2}):(\d{2})$/) {
            let hours = Int(match.1) ?? -1
            let minutes = Int(match.2) ?? -1
            
            guard hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59 else {
                return nil
            }
            
            return String(format: "%02d:%02d", hours, minutes)
        }
        
        // Raw digits format: "930" -> "09:30", "1230" -> "12:30"
        if let formatted = formatRawTimeDigits(trimmed) {
            return formatted
        }
        
        return nil
    }
    
    /// Formats raw time digits like "930" -> "09:30" or "1230" -> "12:30"
    private static func formatRawTimeDigits(_ digits: String) -> String? {
        guard digits.count == 3 || digits.count == 4,
              let _ = Int(digits) else {
            return nil
        }

        let hours: Int
        let minutes: Int

        if digits.count == 3 {
            // Format: HMM -> H:MM
            hours = Int(String(digits.prefix(1))) ?? -1
            minutes = Int(String(digits.suffix(2))) ?? -1
        } else {
            // Format: HHMM -> HH:MM
            hours = Int(String(digits.prefix(2))) ?? -1
            minutes = Int(String(digits.suffix(2))) ?? -1
        }

        guard hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59 else {
            return nil
        }

        return String(format: "%02d:%02d", hours, minutes)
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
}

private struct RawCity: Codable {
    let city: String
    let city_ascii: String
    let country: String
    let timezone: String?
}
