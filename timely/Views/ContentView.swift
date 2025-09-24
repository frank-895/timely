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
                CityPickerView(
                    selectedLocation: $viewModel.selectedLocation1,
                    searchQuery: $viewModel.searchQuery1,
                    filteredLocations: viewModel.filteredLocations1
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                CityPickerView(
                    selectedLocation: $viewModel.selectedLocation2,
                    searchQuery: $viewModel.searchQuery2,
                    filteredLocations: viewModel.filteredLocations2
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer() // Push everything to the top
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}
