import Foundation

/// Utility for converting times between timezones and validating/formatting time strings
struct TimeConverter {

    /// Validates time format: accepts formats like "9:30", "09:30", "21:45"
    /// Normalizes to HH:mm format and validates hours (00-23) and minutes (00-59)
    static func isValidTimeFormat(_ timeString: String) -> Bool {
        let trimmed = timeString.trimmingCharacters(in: .whitespaces)

        // Must be in H:mm or HH:mm format for validation to pass
        guard let match = trimmed.firstMatch(of: /^(\d{1,2}):(\d{2})$/) else {
            return false
        }

        let hours = Int(match.1) ?? -1
        let minutes = Int(match.2) ?? -1

        // Validate ranges
        return hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59
    }

    /// Normalizes time string to HH:mm format (e.g., "9:30" -> "09:30")
    /// Only accepts complete, valid time formats for normalization
    static func normalizeTimeFormat(_ timeString: String) -> String? {
        let trimmed = timeString.trimmingCharacters(in: .whitespaces)

        // Full format: H:mm or HH:mm
        if let match = trimmed.firstMatch(of: /^(\d{1,2}):(\d{2})$/) {
            let hours = Int(match.1) ?? -1
            let minutes = Int(match.2) ?? -1

            guard hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59 else {
                return nil
            }

            return String(format: "%02d:%02d", hours, minutes)
        }

        // Raw digits format: "930" -> "09:30", "1230" -> "12:30"
        if let formatted = formatRawTimeDigits(trimmed) {
            return formatted
        }

        return nil
    }

    /// Formats raw time digits like "930" -> "09:30" or "1230" -> "12:30"
    private static func formatRawTimeDigits(_ digits: String) -> String? {
        guard digits.count == 3 || digits.count == 4,
              let _ = Int(digits) else {
            return nil
        }

        let hours: Int
        let minutes: Int

        if digits.count == 3 {
            // Format: HMM -> H:MM
            hours = Int(String(digits.prefix(1))) ?? -1
            minutes = Int(String(digits.suffix(2))) ?? -1
        } else {
            // Format: HHMM -> HH:MM
            hours = Int(String(digits.prefix(2))) ?? -1
            minutes = Int(String(digits.suffix(2))) ?? -1
        }

        guard hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59 else {
            return nil
        }

        return String(format: "%02d:%02d", hours, minutes)
    }

    /// Converts a time string from one timezone to another
    /// - Parameters:
    ///   - timeString: Time in H:mm or HH:mm format
    ///   - fromLocation: Source location with timezone
    ///   - toLocation: Destination location with timezone
    ///   - date: The date to use for conversion (important for DST)
    /// - Returns: Converted time in HH:mm format, or nil if conversion fails
    static func convertTime(_ timeString: String, from fromLocation: Location, to toLocation: Location, on date: Date = Date()) -> String? {
        // Normalize the time string
        guard let normalizedTime = normalizeTimeFormat(timeString) else {
            return nil
        }

        // Parse the time components
        let components = normalizedTime.split(separator: ":")
        guard components.count == 2,
              let hours = Int(components[0]),
              let minutes = Int(components[1]) else {
            return nil
        }

        // Use the provided date
        let calendar = Calendar.current

        // Create timezone objects
        guard let fromTimeZone = TimeZone(identifier: fromLocation.timezoneIdentifier),
              let toTimeZone = TimeZone(identifier: toLocation.timezoneIdentifier) else {
            return nil
        }

        // Create date components for the time in the source timezone
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = hours
        dateComponents.minute = minutes
        dateComponents.second = 0
        dateComponents.timeZone = fromTimeZone

        // Create the date in the source timezone
        guard let sourceDate = calendar.date(from: dateComponents) else {
            return nil
        }

        // Convert to target timezone
        let formatter = DateFormatter()
        formatter.timeZone = toTimeZone
        formatter.dateFormat = "HH:mm"

        return formatter.string(from: sourceDate)
    }

    /// Converts a time string and returns both the converted time and date
    /// - Parameters:
    ///   - timeString: Time in H:mm or HH:mm format
    ///   - fromLocation: Source location with timezone
    ///   - toLocation: Destination location with timezone
    ///   - date: The date to use for conversion (important for DST)
    /// - Returns: Tuple of (time: String, date: Date) or nil if conversion fails
    static func convertTimeWithDate(_ timeString: String, from fromLocation: Location, to toLocation: Location, on date: Date = Date()) -> (time: String, date: Date)? {
        // Normalize the time string
        guard let normalizedTime = normalizeTimeFormat(timeString) else {
            return nil
        }

        // Parse the time components
        let components = normalizedTime.split(separator: ":")
        guard components.count == 2,
              let hours = Int(components[0]),
              let minutes = Int(components[1]) else {
            return nil
        }

        // Use the provided date
        let calendar = Calendar.current

        // Create timezone objects
        guard let fromTimeZone = TimeZone(identifier: fromLocation.timezoneIdentifier),
              let toTimeZone = TimeZone(identifier: toLocation.timezoneIdentifier) else {
            return nil
        }

        // Create date components for the time in the source timezone
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = hours
        dateComponents.minute = minutes
        dateComponents.second = 0
        dateComponents.timeZone = fromTimeZone

        // Create the date in the source timezone
        guard let sourceDate = calendar.date(from: dateComponents) else {
            return nil
        }

        // Convert to target timezone and get the resulting date
        let formatter = DateFormatter()
        formatter.timeZone = toTimeZone
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: sourceDate)

        // sourceDate already represents the correct moment in time
        // Just return it as-is - it will be formatted correctly in the target timezone
        return (time: timeString, date: sourceDate)
    }
}
