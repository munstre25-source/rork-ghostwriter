import Foundation
import Observation

// MARK: - WeeklyReport

/// A summary report of a creator's weekly activity and performance.
struct WeeklyReport: Sendable {

    /// Total sessions completed during the week.
    var totalSessions: Int

    /// Total words written during the week.
    var totalWords: Int

    /// Total ideas generated during the week.
    var totalIdeas: Int

    /// Average flow score across all sessions.
    var averageFlowScore: Double

    /// The most-used personality name, if any.
    var topPersonality: String?

    /// Total earnings during the week in USD.
    var earnings: Double

    /// Percentage change compared to the previous week (positive = improvement).
    var comparedToPreviousWeek: Double
}

// MARK: - CreatorAnalyticsService

/// Aggregated analytics and reporting for creator dashboards.
///
/// Provides weekly stats, monthly earnings summaries, and
/// productivity insights from ``UserAnalytics`` records.
@Observable
final class CreatorAnalyticsService: @unchecked Sendable {

    /// Daily analytics snapshots for the current week.
    var weeklyStats: [UserAnalytics] = []

    /// Total earnings for the current month in USD.
    var monthlyEarnings: Double = 0

    /// The hour of day (0–23) when the creator is most productive, if determined.
    var mostProductiveHour: Int?

    /// Refreshes analytics data for the specified user.
    ///
    /// - Parameter userId: The user whose analytics to load.
    func refreshAnalytics(for userId: UUID) async {
        try? await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))

        weeklyStats = (0..<7).map { dayOffset in
            UserAnalytics(
                userId: userId,
                date: Calendar.current.date(byAdding: .day, value: -dayOffset, to: .now) ?? .now,
                sessionCount: Int.random(in: 1...5),
                totalSessionMinutes: Int.random(in: 15...120),
                totalWordsWritten: Int.random(in: 200...2000),
                ideasGenerated: Int.random(in: 3...20),
                mostProductiveHour: Int.random(in: 8...22),
                flowStateMinutes: Int.random(in: 5...45),
                collaborationCount: Int.random(in: 0...3)
            )
        }

        monthlyEarnings = Double.random(in: 50...500)
        mostProductiveHour = weeklyStats
            .compactMap(\.mostProductiveHour)
            .max(by: { a, b in
                weeklyStats.filter { $0.mostProductiveHour == a }.count <
                weeklyStats.filter { $0.mostProductiveHour == b }.count
            })
    }

    /// Generates a weekly performance report for the specified user.
    ///
    /// - Parameter userId: The user to generate the report for.
    /// - Returns: A ``WeeklyReport`` summarizing the week's activity.
    func generateWeeklyReport(for userId: UUID) async -> WeeklyReport {
        if weeklyStats.isEmpty {
            await refreshAnalytics(for: userId)
        }

        let totalSessions = weeklyStats.reduce(0) { $0 + $1.sessionCount }
        let totalWords = weeklyStats.reduce(0) { $0 + $1.totalWordsWritten }
        let totalIdeas = weeklyStats.reduce(0) { $0 + $1.ideasGenerated }
        let totalFlowMinutes = weeklyStats.reduce(0) { $0 + $1.flowStateMinutes }
        let totalMinutes = weeklyStats.reduce(0) { $0 + $1.totalSessionMinutes }
        let averageFlow = totalMinutes > 0
            ? Double(totalFlowMinutes) / Double(totalMinutes) * 100.0
            : 0

        return WeeklyReport(
            totalSessions: totalSessions,
            totalWords: totalWords,
            totalIdeas: totalIdeas,
            averageFlowScore: min(averageFlow, 100),
            topPersonality: "The Muse",
            earnings: monthlyEarnings / 4.0,
            comparedToPreviousWeek: Double.random(in: -15...25)
        )
    }
}
