import SwiftUI

struct StreakCalendarView: View {

    let sessionDates: [Date]
    let streakStartDate: Date?

    @State private var displayedMonth: Date = .now

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let daySymbols = Calendar.current.veryShortWeekdaySymbols

    var body: some View {
        VStack(spacing: 12) {
            monthNavigation

            weekdayHeader

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 36)
                    }
                }
            }

            legend
        }
        .padding(16)
        .liquidGlass(cornerRadius: 16)
    }

    // MARK: - Month Navigation

    private var monthNavigation: some View {
        HStack {
            Button {
                shiftMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.ghostText.opacity(0.6))
            }
            .hapticFeedback(.light)

            Spacer()

            Text(displayedMonth, format: .dateTime.month(.wide).year())
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.ghostText)

            Spacer()

            Button {
                shiftMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.ghostText.opacity(0.6))
            }
            .hapticFeedback(.light)
        }
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        HStack(spacing: 4) {
            ForEach(daySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.ghostText.opacity(0.4))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Day Cell

    private func dayCell(for date: Date) -> some View {
        let isSession = isSessionDay(date)
        let isInStreak = isInCurrentStreak(date)
        let isToday = calendar.isDateInToday(date)

        return ZStack {
            if isInStreak {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.ghostEmerald.opacity(0.15))
            }

            if isSession {
                Circle()
                    .fill(isInStreak ? Color.ghostEmerald.opacity(0.3) : Color.ghostCyan.opacity(0.2))
                    .frame(width: 30, height: 30)
            }

            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 13, weight: isToday ? .bold : .regular, design: .rounded))
                .foregroundStyle(
                    isToday ? .ghostCyan :
                    isSession ? .ghostText :
                    .ghostText.opacity(0.3)
                )

            if isSession {
                Circle()
                    .fill(isInStreak ? .ghostEmerald : .ghostCyan)
                    .frame(width: 5, height: 5)
                    .offset(y: 12)
            }
        }
        .frame(height: 36)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(isToday ? Color.ghostCyan.opacity(0.5) : .clear, lineWidth: 1)
        )
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: 20) {
            legendItem(color: .ghostEmerald, label: "Streak")
            legendItem(color: .ghostCyan, label: "Session")
            legendItem(color: .ghostCyan, label: "Today", outlined: true)
        }
        .padding(.top, 4)
    }

    private func legendItem(color: Color, label: String, outlined: Bool = false) -> some View {
        HStack(spacing: 6) {
            if outlined {
                Circle()
                    .stroke(color.opacity(0.5), lineWidth: 1.5)
                    .frame(width: 10, height: 10)
            } else {
                Circle()
                    .fill(color.opacity(0.6))
                    .frame(width: 10, height: 10)
            }
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.ghostText.opacity(0.5))
        }
    }

    // MARK: - Helpers

    private func daysInMonth() -> [Date?] {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstDay = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else {
            return []
        }

        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingBlanks = weekday - calendar.firstWeekday
        let blanks: [Date?] = Array(repeating: nil, count: (leadingBlanks + 7) % 7)

        let days: [Date?] = range.compactMap { day in
            var comps = components
            comps.day = day
            return calendar.date(from: comps)
        }

        return blanks + days
    }

    private func isSessionDay(_ date: Date) -> Bool {
        sessionDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }

    private func isInCurrentStreak(_ date: Date) -> Bool {
        guard let start = streakStartDate else { return false }
        let startOfDay = calendar.startOfDay(for: date)
        let startOfStreak = calendar.startOfDay(for: start)
        let today = calendar.startOfDay(for: .now)
        return startOfDay >= startOfStreak && startOfDay <= today
    }

    private func shiftMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            withAnimation(.easeInOut(duration: 0.25)) {
                displayedMonth = newMonth
            }
        }
    }
}

#Preview {
    let calendar = Calendar.current
    let today = Date.now
    let dates = (0..<12).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
    let streakStart = calendar.date(byAdding: .day, value: -11, to: today) ?? today

    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        StreakCalendarView(sessionDates: dates, streakStartDate: streakStart)
            .padding()
    }
}
