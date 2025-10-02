import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimeConverterViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("timely")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.blue.opacity(0.3), radius: 2, x: 1, y: 1)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        // Open license file or show license info
                        if let url = URL(string: "https://github.com/frank-895/timely/blob/main/LICENSE") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        Text("LICENCE")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("View License")
                    .onHover { isHovering in
                        if isHovering {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }

                    Button(action: {
                        if let url = URL(string: "https://github.com/frank-895/timely") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        Image("github")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(.plain)
                    .help("View on GitHub")
                    .onHover { isHovering in
                        if isHovering {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }
                }
            }

            HStack(alignment: .top, spacing: 40) {
                VStack {
                    ValidatedTimeInputView(
                        inputState: viewModel.timeInput,
                        validationManager: viewModel.validationManager,
                        onTimeChanged: { timeString in
                            // The conversion will be triggered automatically by the 
                            // Combine publisher in setupTimeConversion()
                        }
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)

                VStack {
                    Text(viewModel.convertedTime)
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
