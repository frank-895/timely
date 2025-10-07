import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimeConverterViewModel()
    @State private var isLicenseHovered = false
    @State private var isGitHubHovered = false
    @State private var isSwapHovered = false
    @State private var isClockHovered = false
    @State private var isQuitHovered = false
    @State private var isCalendarHovered = false
    @State private var showDatePicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("timely")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundColor(.blue)
                
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
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.1), value: false)

                    Button(action: {
                        if let url = URL(string: "https://github.com/frank-895/timely") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        Image("github")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.secondary)
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
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.1), value: false)

                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Quit")
                    .onHover { isHovering in
                        isQuitHovered = isHovering
                    }
                    .onChange(of: isQuitHovered) { _, newValue in
                        if newValue {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }
                }
            }

            HStack(alignment: .top, spacing: 40) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(formattedDate(viewModel.selectedDate))
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)

                    HStack {
                        ValidatedTimeInputView(
                            inputState: viewModel.timeInput,
                            validationManager: viewModel.validationManager,
                            onTimeChanged: { timeString in
                                // The conversion will be triggered automatically by the
                                // Combine publisher in setupTimeConversion()
                            }
                        )

                        Button(action: {
                            viewModel.setCurrentTime()
                        }) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        .help("Set to current time")
                        .onHover { isHovering in
                            isClockHovered = isHovering
                        }
                        .onChange(of: isClockHovered) { _, newValue in
                            if newValue {
                                NSCursor.pointingHand.set()
                            } else {
                                NSCursor.arrow.set()
                            }
                        }

                        Button(action: {
                            showDatePicker.toggle()
                        }) {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        .help("Choose date")
                        .onHover { isHovering in
                            isCalendarHovered = isHovering
                        }
                        .onChange(of: isCalendarHovered) { _, newValue in
                            if newValue {
                                NSCursor.pointingHand.set()
                            } else {
                                NSCursor.arrow.set()
                            }
                        }
                        .popover(isPresented: $showDatePicker, arrowEdge: .bottom) {
                            CustomCalendarView(
                                selectedDate: $viewModel.selectedDate,
                                isPresented: $showDatePicker
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 8) {
                    Text(formattedDate(viewModel.convertedDate, timeZone: viewModel.convertedTimeZone))
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)

                    Text(viewModel.convertedTime)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            HStack(alignment: .top, spacing: 20) {
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

                Button(action: {
                    viewModel.swapLocations()
                }) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help("Swap locations")
                .onHover { isHovering in
                    isSwapHovered = isHovering
                }
                .onChange(of: isSwapHovered) { _, newValue in
                    if newValue {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }
                .padding(.top, 8)

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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }

    private func formattedDate(_ date: Date, timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
}
