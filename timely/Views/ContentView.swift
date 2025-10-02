import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimeConverterViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("timely :)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color.blue.opacity(0.3), radius: 2, x: 1, y: 1)

            HStack(alignment: .top, spacing: 40) {
                VStack {
                    ValidatedTimeInputView(
                        inputState: viewModel.timeInput,
                        validationManager: viewModel.validationManager,
                        onTimeChanged: { timeString in
                            // Handle time changes if needed for conversion logic later
                            print("Time changed to: \(timeString)")
                        }
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)

                VStack {
                    Text("09:45")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            HStack(alignment: .top, spacing: 40) {
                ValidatedCityPickerView(
                    selectedLocation: $viewModel.selectedLocation1,
                    inputState: viewModel.location1Input,
                    filteredLocations: viewModel.filteredLocations1,
                    validationManager: viewModel.validationManager,
                    onLocationSelected: { location in
                        // Defer the update to avoid publishing during view updates
                        DispatchQueue.main.async {
                            viewModel.selectedLocation1 = location
                        }
                    }
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                ValidatedCityPickerView(
                    selectedLocation: $viewModel.selectedLocation2,
                    inputState: viewModel.location2Input,
                    filteredLocations: viewModel.filteredLocations2,
                    validationManager: viewModel.validationManager,
                    onLocationSelected: { location in
                        // Defer the update to avoid publishing during view updates
                        DispatchQueue.main.async {
                            viewModel.selectedLocation2 = location
                        }
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
