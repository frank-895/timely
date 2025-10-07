import SwiftUI

struct ValidatedTimeInputView: View {
    @ObservedObject var inputState: InputFieldState
    var validationManager: InputValidationManager
    var onTimeChanged: ((String) -> Void)?

    @FocusState private var focusedField: Field?
    @State private var hourText: String = "00"
    @State private var minuteText: String = "00"
    @State private var isUpdatingFromUser: Bool = false

    enum Field {
        case hour
        case minute
    }

    var body: some View {
        HStack(spacing: 4) {
            // Hour input
            TextField("00", text: $hourText)
                .focused($focusedField, equals: .hour)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .frame(width: 80)
                .onChange(of: hourText) { oldValue, newValue in
                    isUpdatingFromUser = true
                    hourText = formatHourInput(newValue)

                    // Auto-pad and advance for single digits 3-9
                    if hourText.count == 1, let digit = Int(hourText), digit >= 3 {
                        // Pad with leading zero (e.g., "9" -> "09")
                        hourText = String(format: "%02d", digit)
                        updateTimeString()
                        focusedField = .minute
                    } else if hourText.count == 2 {
                        // Two digits entered - update and advance
                        updateTimeString()
                        focusedField = .minute
                    }
                    // For single digit 0, 1, or 2 - don't update time string yet, wait for second digit
                    isUpdatingFromUser = false
                }
                .onTapGesture {
                    focusedField = .hour
                }

            // Colon separator
            Text(":")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            // Minute input
            TextField("00", text: $minuteText)
                .focused($focusedField, equals: .minute)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .frame(width: 80)
                .onChange(of: minuteText) { oldValue, newValue in
                    isUpdatingFromUser = true

                    // Detect backspace to empty - move back to hour
                    if !oldValue.isEmpty && newValue.isEmpty {
                        focusedField = .hour
                        isUpdatingFromUser = false
                        return
                    }

                    minuteText = formatMinuteInput(newValue)

                    // Only update time string when we have 2 digits or a valid minute
                    if minuteText.count == 2 {
                        updateTimeString()
                    }
                    // For single digit, wait for second digit before updating

                    isUpdatingFromUser = false
                }
                .onTapGesture {
                    focusedField = .minute
                }
        }
        .onHover { isHovered in
            if isHovered {
                NSCursor.iBeam.set()
            } else {
                NSCursor.arrow.set()
            }
        }
        .onChange(of: focusedField) { oldValue, newValue in
            inputState.isFocused = newValue != nil

            // When leaving the hour field with a single digit, pad it
            if oldValue == .hour && newValue != .hour && hourText.count == 1 {
                if let digit = Int(hourText) {
                    hourText = String(format: "%02d", digit)
                    updateTimeString()
                }
            }

            // When leaving the minute field with a single digit, pad it
            if oldValue == .minute && newValue != .minute && minuteText.count == 1 {
                if let digit = Int(minuteText) {
                    minuteText = String(format: "%02d", digit)
                    updateTimeString()
                }
            }
        }
        .onChange(of: inputState.currentValue) { oldValue, newValue in
            // Only sync from external changes when user is NOT actively typing
            if !isUpdatingFromUser {
                parseTimeString(newValue)
            }
        }
        .onAppear {
            parseTimeString(inputState.currentValue)
            // Auto-focus on hour field when view appears
            DispatchQueue.main.async {
                focusedField = .hour
            }
        }
    }
    
    private func formatHourInput(_ input: String) -> String {
        let cleaned = input.filter { $0.isNumber }
        if cleaned.isEmpty { return "" }

        // If we have more than 2 digits, take the last 2 (most recent input)
        let truncated = cleaned.count > 2 ? String(cleaned.suffix(2)) : cleaned
        let number = Int(truncated) ?? 0

        // Clamp hours to 0-23 range
        if number > 23 {
            return "23"
        }

        return truncated
    }
    
    private func formatMinuteInput(_ input: String) -> String {
        let cleaned = input.filter { $0.isNumber }
        if cleaned.isEmpty { return "" }

        // If we have more than 2 digits, take the last 2 (most recent input)
        let truncated = cleaned.count > 2 ? String(cleaned.suffix(2)) : cleaned
        let number = Int(truncated) ?? 0

        // Clamp minutes to 0-59 range
        // For 2-digit inputs, check if it exceeds 59
        if truncated.count == 2 && number > 59 {
            return "59"
        }

        // For single digit 6-9, they can only be first digit of valid minutes
        // But allow them for now - validation happens when complete
        return truncated
    }
    
    private func updateTimeString() {
        let hour = hourText.isEmpty ? "00" : String(format: "%02d", Int(hourText) ?? 0)
        let minute = minuteText.isEmpty ? "00" : String(format: "%02d", Int(minuteText) ?? 0)

        let timeString = "\(hour):\(minute)"
        inputState.currentValue = timeString

        onTimeChanged?(timeString)
    }
    
    private func parseTimeString(_ timeString: String) {
        let components = timeString.components(separatedBy: ":")
        if components.count == 2 {
            hourText = components[0]
            minuteText = components[1]
        }
    }
}