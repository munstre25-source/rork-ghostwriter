import Foundation

/// Aggregated statistics for a creator's dashboard display.
///
/// This is a lightweight value type used for presenting computed metrics
/// in the UI. It is not persisted directly — values are derived from
/// the creator's sessions, clips, and earnings records.
struct CreatorStats: Codable, Hashable, Sendable {

    /// Total number of creative sessions completed.
    var totalSessions: Int

    /// Total words written across all sessions.
    var totalWords: Int

    /// Total ideas generated across all sessions.
    var totalIdeas: Int

    /// Average flow score across all sessions (0–100).
    var averageFlowScore: Double

    /// Lifetime total earnings in USD.
    var totalEarnings: Double

    /// Lifetime total views across all clips.
    var totalClipViews: Int

    /// Name of the personality used most frequently, if any.
    var mostUsedPersonality: String?

    /// Current consecutive-day session streak.
    var currentStreak: Int

    /// Longest consecutive-day session streak ever achieved.
    var longestStreak: Int

    /// Creates a new stats snapshot.
    ///
    /// - Parameters:
    ///   - totalSessions: Total sessions completed. Defaults to `0`.
    ///   - totalWords: Total words written. Defaults to `0`.
    ///   - totalIdeas: Total ideas generated. Defaults to `0`.
    ///   - averageFlowScore: Average flow score. Defaults to `0`.
    ///   - totalEarnings: Total earnings. Defaults to `0`.
    ///   - totalClipViews: Total clip views. Defaults to `0`.
    ///   - mostUsedPersonality: Most-used personality name.
    ///   - currentStreak: Current streak length. Defaults to `0`.
    ///   - longestStreak: Longest streak length. Defaults to `0`.
    init(
        totalSessions: Int = 0,
        totalWords: Int = 0,
        totalIdeas: Int = 0,
        averageFlowScore: Double = 0,
        totalEarnings: Double = 0,
        totalClipViews: Int = 0,
        mostUsedPersonality: String? = nil,
        currentStreak: Int = 0,
        longestStreak: Int = 0
    ) {
        self.totalSessions = totalSessions
        self.totalWords = totalWords
        self.totalIdeas = totalIdeas
        self.averageFlowScore = averageFlowScore
        self.totalEarnings = totalEarnings
        self.totalClipViews = totalClipViews
        self.mostUsedPersonality = mostUsedPersonality
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
    }
}
