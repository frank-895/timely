import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimeConverterViewModel()

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack(spacing: 40) {
                Text("12:34")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                Text("09:45")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
            }

            HStack(alignment: .top, spacing: 40) {
                ValidatedCityPickerView(
                    selectedLocation: $viewModel.selectedLocation1,
                    inputState: viewModel.location1Input,
                    filteredLocations: viewModel.filteredLocations1,
                    validationManager: viewModel.validationManager,
                    onLocationSelected: { location in
                        // Update the selected location when a city is picked
                        viewModel.selectedLocation1 = location
                    }
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                ValidatedCityPickerView(
                    selectedLocation: $viewModel.selectedLocation2,
                    inputState: viewModel.location2Input,
                    filteredLocations: viewModel.filteredLocations2,
                    validationManager: viewModel.validationManager,
                    onLocationSelected: { location in
                        // Update the selected location when a city is picked
                        viewModel.selectedLocation2 = location
                    }
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer() // Push everything to the top
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}
