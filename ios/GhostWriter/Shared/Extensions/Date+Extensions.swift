import Foundation

extension Date {
    /// A human-readable "time ago" string (e.g. "5m ago", "2h ago", "3d ago").
    var timeAgo: String {
        let interval = -timeIntervalSinceNow
        switch interval {
        case ..<60:
            return "just now"
        case 60..<3600:
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        case 3600..<86400:
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        case 86400..<604_800:
            let days = Int(interval / 86400)
            return "\(days)d ago"
        case 604_800..<2_592_000:
            let weeks = Int(interval / 604_800)
            return "\(weeks)w ago"
        default:
            let months = Int(interval / 2_592_000)
            return "\(months)mo ago"
        }
    }

    /// Whether this date falls on the current calendar day.
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Whether this date falls on the previous calendar day.
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// The start of the calendar day (midnight) for this date.
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns `true` if this date is on the same calendar day as `other`.
    /// - Parameter other: The date to compare against.
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    /// Formats a time interval as a human-readable duration string (e.g. "1h 23m").
    ///
    /// Intended for session durations. The receiver is treated as the session start date,
    /// and the duration is measured to `Date.now`.
    var formattedDuration: String {
        let interval = -timeIntervalSinceNow
        return Self.formatDuration(interval)
    }

    /// Formats a `TimeInterval` into a compact duration string.
    /// - Parameter interval: Duration in seconds.
    /// - Returns: A string like "45s", "12m", or "1h 23m".
    static func formatDuration(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(max(0, interval))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}
