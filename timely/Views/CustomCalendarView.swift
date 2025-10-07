import SwiftUI

struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool

    @State private var displayedMonth: Date = Date()

    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack(spacing: 16) {
            // Month/Year Header with Navigation
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }

                Spacer()

                Text(monthYearString)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))

                Spacer()

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }
            }
            .padding(.horizontal, 8)

            // Days of Week Header
            HStack(spacing: 4) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(datesInMonth, id: \.self) { date in
                    if let date = date {
                        DateCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 32)
                    }
                }
            }

            Divider()

            // Action Buttons
            HStack {
                Button("Today") {
                    selectedDate = Date()
                    displayedMonth = Date()
                }
                .buttonStyle(.borderless)
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }

                Spacer()

                Button("Close") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(16)
        .frame(width: 280)
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private var datesInMonth: [Date?] {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }

        guard let monthRange = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingEmptyDays = firstWeekday - 1

        var dates: [Date?] = Array(repeating: nil, count: leadingEmptyDays)

        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                dates.append(date)
            }
        }

        // Pad to complete weeks
        while dates.count % 7 != 0 {
            dates.append(nil)
        }

        return dates
    }

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let onSelect: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onSelect) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 13, weight: isToday ? .semibold : .regular, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: isToday ? 2 : 0)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
            if hovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
    }

    private var foregroundColor: Color {
        if !isCurrentMonth {
            return .secondary.opacity(0.4)
        }
        if isSelected {
            return .white
        }
        if isToday {
            return .blue
        }
        return .primary
    }

    private var backgroundColor: Color {
        if isSelected {
            return .blue
        }
        if isHovered && isCurrentMonth {
            return .blue.opacity(0.1)
        }
        return .clear
    }

    private var borderColor: Color {
        if isToday && !isSelected {
            return .blue
        }
        return .clear
    }
}
