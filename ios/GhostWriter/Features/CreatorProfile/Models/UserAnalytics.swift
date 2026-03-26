import Foundation
import SwiftData

/// A daily analytics snapshot capturing a creator's productivity metrics.
///
/// Each record represents one calendar day and aggregates session, writing,
/// collaboration, and flow-state data for trend analysis.
@Model
final class UserAnalytics: @unchecked Sendable {

    /// Unique identifier for this analytics record.
    @Attribute(.unique) var id: UUID

    /// The user this record belongs to.
    var userId: UUID

    /// The calendar date this record covers.
    var date: Date

    /// Number of creative sessions completed on this date.
    var sessionCount: Int

    /// Total minutes spent in creative sessions.
    var totalSessionMinutes: Int

    /// Total words written across all sessions.
    var totalWordsWritten: Int

    /// Total ideas generated across all sessions.
    var ideasGenerated: Int

    /// The hour of day (0–23) when the user was most productive, if determinable.
    var mostProductiveHour: Int?

    /// The day of the week when the user was most productive, if determinable.
    var mostProductiveDay: String?

    /// The personality used most frequently on this date, if any.
    var favoritePersonality: UUID?

    /// Distribution of detected moods keyed by mood label, with occurrence counts.
    var moodDistribution: [String: Int]

    /// Total minutes the user spent in a flow state.
    var flowStateMinutes: Int

    /// Number of collaborative sessions or interactions on this date.
    var collaborationCount: Int

    /// Creates a new daily analytics record.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - userId: The owning user's ID.
    ///   - date: The calendar date. Defaults to today.
    ///   - sessionCount: Sessions completed. Defaults to `0`.
    ///   - totalSessionMinutes: Total session minutes. Defaults to `0`.
    ///   - totalWordsWritten: Words written. Defaults to `0`.
    ///   - ideasGenerated: Ideas generated. Defaults to `0`.
    ///   - mostProductiveHour: Peak productivity hour.
    ///   - mostProductiveDay: Peak productivity weekday name.
    ///   - favoritePersonality: Most-used personality ID.
    ///   - moodDistribution: Mood occurrence counts. Defaults to empty.
    ///   - flowStateMinutes: Minutes in flow state. Defaults to `0`.
    ///   - collaborationCount: Collaborations. Defaults to `0`.
    init(
        id: UUID = UUID(),
        userId: UUID,
        date: Date = .now,
        sessionCount: Int = 0,
        totalSessionMinutes: Int = 0,
        totalWordsWritten: Int = 0,
        ideasGenerated: Int = 0,
        mostProductiveHour: Int? = nil,
        mostProductiveDay: String? = nil,
        favoritePersonality: UUID? = nil,
        moodDistribution: [String: Int] = [:],
        flowStateMinutes: Int = 0,
        collaborationCount: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.sessionCount = sessionCount
        self.totalSessionMinutes = totalSessionMinutes
        self.totalWordsWritten = totalWordsWritten
        self.ideasGenerated = ideasGenerated
        self.mostProductiveHour = mostProductiveHour
        self.mostProductiveDay = mostProductiveDay
        self.favoritePersonality = favoritePersonality
        self.moodDistribution = moodDistribution
        self.flowStateMinutes = flowStateMinutes
        self.collaborationCount = collaborationCount
    }
}
