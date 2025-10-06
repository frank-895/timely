import SwiftUI

struct ValidatedTimeInputView: View {
    @ObservedObject var inputState: InputFieldState
    var validationManager: InputValidationManager
    var onTimeChanged: ((String) -> Void)?

    @FocusState private var focusedField: Field?
    @State private var hourText: String = ""
    @State private var minuteText: String = ""

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
                    hourText = formatHourInput(newValue)

                    // Auto-pad and advance for single digits 3-9
                    if hourText.count == 1, let digit = Int(hourText), digit >= 3 {
                        // Pad with leading zero (e.g., "9" -> "09")
                        hourText = String(format: "%02d", digit)
                        updateTimeString()
                        focusedField = .minute
                    } else {
                        updateTimeString()
                        // Auto-advance to minutes when 2 digits entered
                        if hourText.count == 2 {
                            focusedField = .minute
                        }
                    }
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
                    minuteText = formatMinuteInput(newValue)
                    updateTimeString()
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
        }
        .onChange(of: inputState.currentValue) { oldValue, newValue in
            // Update local state when validation system changes the value
            // Always update if not currently typing (focusedField will be set when typing)
            parseTimeString(newValue)
        }
        .onAppear {
            parseTimeString(inputState.currentValue)
            // Auto-focus on hour field when view appears (with delay to allow value to be set first)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
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
        if number > 59 {
            return "59"
        }

        return truncated
    }
    
    private func updateTimeString() {
        let hour = hourText.isEmpty ? "00" : String(format: "%02d", Int(hourText) ?? 0)
        let minute = minuteText.isEmpty ? "00" : String(format: "%02d", Int(minuteText) ?? 0)
        
        let timeString = "\(hour):\(minute)"
        
        DispatchQueue.main.async {
            inputState.currentValue = timeString
        }
        
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