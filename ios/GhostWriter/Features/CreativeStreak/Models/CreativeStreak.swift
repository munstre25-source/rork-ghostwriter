import Foundation
import SwiftData

/// Tracks a user's consecutive-day creative session streak.
///
/// The streak resets if a calendar day passes without a recorded session.
/// Use ``recordSession()`` after each completed session to keep the streak current.
@Model
final class CreativeStreak: @unchecked Sendable {

    /// Unique identifier for this streak record.
    @Attribute(.unique) var id: UUID

    /// The user this streak belongs to.
    var userId: UUID

    /// The current consecutive-day streak count.
    var currentStreak: Int

    /// The longest streak this user has ever achieved.
    var longestStreak: Int

    /// Date of the most recent session in the streak.
    var lastSessionDate: Date

    /// Date the current streak began.
    var streakStartDate: Date

    /// Total sessions completed during the current streak.
    var totalSessionsInStreak: Int

    /// Total words written during the current streak.
    var totalWordsInStreak: Int

    /// Creates a new creative streak record.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - userId: The owning user's ID.
    ///   - currentStreak: Current streak length. Defaults to `0`.
    ///   - longestStreak: Longest streak ever. Defaults to `0`.
    ///   - lastSessionDate: Date of the last session. Defaults to now.
    ///   - streakStartDate: When the current streak started. Defaults to now.
    ///   - totalSessionsInStreak: Sessions in the current streak. Defaults to `0`.
    ///   - totalWordsInStreak: Words in the current streak. Defaults to `0`.
    init(
        id: UUID = UUID(),
        userId: UUID,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastSessionDate: Date = .now,
        streakStartDate: Date = .now,
        totalSessionsInStreak: Int = 0,
        totalWordsInStreak: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastSessionDate = lastSessionDate
        self.streakStartDate = streakStartDate
        self.totalSessionsInStreak = totalSessionsInStreak
        self.totalWordsInStreak = totalWordsInStreak
    }

    /// Records a completed session and updates streak counters.
    ///
    /// If the previous session was yesterday, the streak continues.
    /// If the previous session was today, only counters are incremented.
    /// Otherwise the streak resets to 1.
    ///
    /// - Parameter wordsWritten: Number of words written in the session. Defaults to `0`.
    func recordSession(wordsWritten: Int = 0) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let lastDay = calendar.startOfDay(for: lastSessionDate)

        let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

        switch daysBetween {
        case 0:
            // Same day — increment counters only.
            break
        case 1:
            // Consecutive day — extend the streak.
            currentStreak += 1
        default:
            // Gap detected — reset.
            currentStreak = 1
            streakStartDate = today
            totalSessionsInStreak = 0
            totalWordsInStreak = 0
        }

        totalSessionsInStreak += 1
        totalWordsInStreak += wordsWritten
        lastSessionDate = .now

        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }
}
