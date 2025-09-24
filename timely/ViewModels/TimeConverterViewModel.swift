import SwiftUI
import Combine

@MainActor
class TimeConverterViewModel: ObservableObject {
    @Published var allLocations: [Location] = []

    @Published var selectedLocation1: Location?
    @Published var selectedLocation2: Location?

    @Published var searchQuery1: String = ""
    @Published var searchQuery2: String = ""

    @Published var filteredLocations1: [Location] = []
    @Published var filteredLocations2: [Location] = []

    private var cancellables = Set<AnyCancellable>()
    private let maxResults = 10

    init() {
        loadCities()
        setupFiltering()
    }

    private func loadCities() {
        guard let url = Bundle.main.url(forResource: "cities", withExtension: "json") else {
            print("❌ cities.json not found")
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
            self.selectedLocation1 = locations.first
            self.selectedLocation2 = locations.dropFirst().first

        } catch {
            print("❌ Failed to load cities: \(error)")
        }
    }

    private func setupFiltering() {
        // Picker 1
        $searchQuery1
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .map { [weak self] query in
                guard let self = self else { return [] }
                guard !query.isEmpty else { return [] }
                return self.allLocations
                    .filter { $0.nameLowercased.contains(query.lowercased()) }
                    .prefix(self.maxResults)
                    .map { $0 }
            }
            .assign(to: \.filteredLocations1, on: self)
            .store(in: &cancellables)

        // Picker 2
        $searchQuery2
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .map { [weak self] query in
                guard let self = self else { return [] }
                guard !query.isEmpty else { return [] }
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
