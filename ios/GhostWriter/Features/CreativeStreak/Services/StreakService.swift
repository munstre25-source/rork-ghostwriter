import Foundation
import Observation

// MARK: - StreakError

/// Errors that can occur during streak operations.
enum StreakError: Error, LocalizedError, Sendable {
    case loadFailed
    case recordFailed
    case challengeNotFound
    case alreadyJoined

    var errorDescription: String? {
        switch self {
        case .loadFailed:           "Failed to load streak data."
        case .recordFailed:         "Failed to record session completion."
        case .challengeNotFound:    "Challenge not found."
        case .alreadyJoined:        "You have already joined this challenge."
        }
    }
}

// MARK: - StreakService

/// Manages creative streak tracking and weekly challenge participation.
@Observable
final class StreakService: @unchecked Sendable {

    /// The current user's streak record, if loaded.
    var currentStreak: CreativeStreak?

    /// The currently active weekly challenge, if any.
    var activeChallenge: WeeklyChallenge?

    /// Loads the streak record for the specified user.
    ///
    /// - Parameter userId: The user whose streak to load.
    /// - Throws: ``StreakError/loadFailed`` if the streak cannot be loaded.
    func loadStreak(for userId: UUID) async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 0.3...1.0)))

        currentStreak = CreativeStreak(
            userId: userId,
            currentStreak: Int.random(in: 1...30),
            longestStreak: Int.random(in: 10...60),
            totalSessionsInStreak: Int.random(in: 5...100),
            totalWordsInStreak: Int.random(in: 1000...50000)
        )
    }

    /// Records a completed session and updates the streak.
    ///
    /// - Throws: ``StreakError/recordFailed`` if the streak cannot be updated.
    func recordSessionCompletion() async throws {
        guard let streak = currentStreak else {
            throw StreakError.recordFailed
        }

        try await Task.sleep(for: .seconds(Double.random(in: 0.2...0.5)))

        streak.recordSession(wordsWritten: Int.random(in: 100...1000))
        print("[Streak] Recorded session — current streak: \(streak.currentStreak)")
    }

    /// Loads the currently active weekly challenge, if one exists.
    ///
    /// - Returns: The active ``WeeklyChallenge``, or `nil` if none is active.
    func loadActiveChallenge() async throws -> WeeklyChallenge? {
        try await Task.sleep(for: .seconds(Double.random(in: 0.3...0.8)))

        let challenge = WeeklyChallenge(
            title: "Flash Fiction Friday",
            challengeDescription: "Write a complete short story in under 500 words using The Muse personality.",
            targetWordCount: 500,
            targetSessionCount: 3,
            startDate: Calendar.current.date(byAdding: .day, value: -2, to: .now) ?? .now,
            endDate: Calendar.current.date(byAdding: .day, value: 5, to: .now) ?? .now,
            participantCount: Int.random(in: 50...500),
            sponsorAmount: 250.00
        )

        activeChallenge = challenge
        return challenge
    }

    /// Joins a weekly challenge.
    ///
    /// - Parameter challenge: The challenge to join.
    /// - Throws: ``StreakError/alreadyJoined`` if already participating.
    func joinChallenge(_ challenge: WeeklyChallenge) async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 0.3...0.8)))

        challenge.participantCount += 1
        activeChallenge = challenge
        print("[Streak] Joined challenge: \(challenge.title)")
    }
}
