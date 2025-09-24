import SwiftUI
import Combine

/// Root content view.
/// Shows two static placeholder times (for now) and two dropdown menus
/// to choose locations. The dropdowns are bound to `selectedIndex1/2`.
struct ContentView: View {
    @StateObject private var viewModel = TimeConverterViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Placeholder times
            HStack(spacing: 40) {
                Text("12:34")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                Text("09:45")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
            }
            
            // MARK: - Dropdowns for locations
            HStack(spacing: 40) {
                // Left column (time + dropdown)
                VStack(spacing: 8) {
                    Picker("Location 1", selection: $viewModel.selectedIndex1) {
                        ForEach(viewModel.availableLocations.indices, id: \.self) { idx in
                            Text(viewModel.availableLocations[idx].name).tag(idx)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Text("Selected: \(viewModel.selectedLocation1.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Right column (time + dropdown)
                VStack(spacing: 8) {
                    Picker("Location 2", selection: $viewModel.selectedIndex2) {
                        ForEach(viewModel.availableLocations.indices, id: \.self) { idx in
                            Text(viewModel.availableLocations[idx].name).tag(idx)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Text("Selected: \(viewModel.selectedLocation2.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}
