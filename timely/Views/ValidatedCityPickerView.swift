import SwiftUI

struct ValidatedCityPickerView: View {
    @Binding var selectedLocation: Location?
    @ObservedObject var inputState: InputFieldState
    var filteredLocations: [Location]
    var validationManager: InputValidationManager
    var onLocationSelected: ((Location) -> Void)?

    @State private var isExpanded = false
    @State private var selectedIndex = 0
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            textField

            // Dropdown content that affects layout
            if isExpanded && !filteredLocations.isEmpty {
                cityList
            }
        }
        .onChange(of: inputState.currentValue) {
            updateExpansionState()
        }
        .onChange(of: isTextFieldFocused) { oldValue, newValue in
            // Only update focus state, don't validate here
            // Validation happens in InputValidationManager with proper deferred timing
            inputState.isFocused = newValue

            if newValue {
                updateExpansionState()
            } else {
                isExpanded = false
            }
        }
        .onChange(of: filteredLocations) { oldValue, newValue in
            // Update expansion state when filtered locations change
            updateExpansionState()
        }
    }
    
    private func updateExpansionState() {
        let shouldExpand = !inputState.currentValue.isEmpty &&
                          !isValidCompleteSelection() &&
                          isTextFieldFocused

        isExpanded = shouldExpand
        selectedIndex = 0
    }
    
    private func isValidCompleteSelection() -> Bool {
        guard let selectedLocation = selectedLocation else { return false }
        let expectedText = "\(selectedLocation.name), \(selectedLocation.country)"
        return inputState.currentValue == expectedText
    }
    
    // Break down into computed properties
    private var textField: some View {
        TextField("Search city...", text: $inputState.currentValue)
            .focused($isTextFieldFocused)
            .padding(8)
            .background(textFieldBackground)
            .onTapGesture {
                isTextFieldFocused = true
            }
            .onHover { isHovered in
                if isHovered {
                    NSCursor.iBeam.set() // Text cursor for input fields
                } else {
                    NSCursor.arrow.set()
                }
            }
            .onKeyPress { keyPress in
                handleKeyPress(keyPress)
            }
    }
    
    private var textFieldBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(inputState.currentValue == inputState.lastValid ? Color.gray.opacity(0.5) : Color.red.opacity(0.7))
    }
    
    private var cityList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(filteredLocations.prefix(10), id: \.id) { city in
                    cityRow(city: city)
                }
            }
        }
        .frame(height: min(CGFloat(filteredLocations.prefix(10).count) * 40, 160)) // Dynamic height based on actual cities
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .overlay(dropdownBorder)
        .zIndex(1000) // Still keep high z-index for stacking
    }
    
    private var dropdownBorder: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
    }
    
    private func cityRow(city: Location) -> some View {
        let cityIndex = Array(filteredLocations.prefix(10)).firstIndex(where: { $0.id == city.id }) ?? 0
        let isSelected = cityIndex == selectedIndex && isExpanded
        
        return VStack(spacing: 0) {
            Button(action: {
                selectCity(city)
            }) {
                cityRowContent(city: city, isSelected: isSelected)
            }
            .buttonStyle(.plain)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.05))
            .onHover { isHovered in
                if isHovered {
                    selectedIndex = cityIndex // Update selection on hover
                    NSCursor.pointingHand.set()
                } else {
                    NSCursor.arrow.set()
                }
            }
            
            if shouldShowDivider(for: city) {
                Divider()
            }
        }
    }
    
    private func cityRowContent(city: Location, isSelected: Bool) -> some View {
        HStack {
            Text("\(city.name), \(city.country)")
                .foregroundColor(isSelected ? .blue : .black)
                .fontWeight(isSelected ? .medium : .regular)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
    
    private func selectCity(_ city: Location) {
        // Update the selectedLocation binding
        selectedLocation = city

        // Use validation manager's proper method for programmatic updates
        let cityText = "\(city.name), \(city.country)"
        validationManager.setFieldValue(inputState.id, to: cityText)

        // Update UI state
        isExpanded = false
        selectedIndex = 0
        isTextFieldFocused = false

        // Notify callback
        onLocationSelected?(city)
    }
    
    private func handleKeyPress(_ keyPress: KeyPress) -> KeyPress.Result {
        guard isExpanded && !filteredLocations.isEmpty else { return .ignored }
        
        let maxIndex = min(filteredLocations.count, 10) - 1
        
        switch keyPress.key {
        case .downArrow:
            selectedIndex = min(selectedIndex + 1, maxIndex)
            return .handled
        case .upArrow:
            selectedIndex = max(selectedIndex - 1, 0)
            return .handled
        case .return:
            if selectedIndex < filteredLocations.count {
                let selectedCity = Array(filteredLocations.prefix(10))[selectedIndex]
                selectCity(selectedCity)
            }
            return .handled
        case .escape:
            isExpanded = false
            selectedIndex = 0
            isTextFieldFocused = false
            return .handled
        default:
            return .ignored
        }
    }
    
    private func shouldShowDivider(for city: Location) -> Bool {
        city.id != filteredLocations.prefix(10).last?.id
    }
}