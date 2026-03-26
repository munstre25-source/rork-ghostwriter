import Foundation
import Observation

// MARK: - LeaderboardError

/// Errors that can occur during leaderboard operations.
enum LeaderboardError: Error, LocalizedError, Sendable {
    case loadFailed
    case invalidCategory

    var errorDescription: String? {
        switch self {
        case .loadFailed:       "Failed to load the leaderboard."
        case .invalidCategory:  "Invalid leaderboard category."
        }
    }
}

// MARK: - LeaderboardService

/// Manages leaderboard data retrieval and filtering by category.
@Observable
final class LeaderboardService: @unchecked Sendable {

    /// The current leaderboard entries.
    var entries: [LeaderboardEntry] = []

    /// The currently selected leaderboard category.
    var currentCategory: LeaderboardCategory = .mostViewed

    private let mockUsernames = [
        "luna_writes", "creative_storm", "mind_architect", "story_weaver",
        "word_smith", "prose_master", "ink_flow", "dream_scribe",
        "thought_crafter", "verse_runner"
    ]

    /// Loads leaderboard entries for the specified category.
    ///
    /// - Parameter category: The leaderboard category to display.
    /// - Throws: ``LeaderboardError/loadFailed`` if data cannot be loaded.
    func loadLeaderboard(category: LeaderboardCategory) async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))

        currentCategory = category

        entries = mockUsernames.enumerated().map { index, username in
            LeaderboardEntry(
                userId: UUID(),
                username: username,
                score: Int.random(in: 100...10000) * (mockUsernames.count - index),
                rank: index + 1,
                category: category
            )
        }
        .sorted { $0.score > $1.score }
        .enumerated()
        .map { index, entry in
            LeaderboardEntry(
                id: entry.id,
                userId: entry.userId,
                username: entry.username,
                score: entry.score,
                rank: index + 1,
                category: entry.category
            )
        }
    }

    /// Loads a leaderboard filtered to only the user's friends.
    ///
    /// - Returns: An array of friend ``LeaderboardEntry`` records.
    /// - Throws: ``LeaderboardError/loadFailed`` if data cannot be loaded.
    func loadFriendLeaderboard(category: LeaderboardCategory) async throws -> [LeaderboardEntry] {
        try await Task.sleep(for: .milliseconds(550))

        let friendNames = Array(mockUsernames.prefix(5))

        var friends = friendNames.enumerated().map { index, username in
            LeaderboardEntry(
                userId: UUID(),
                username: username,
                score: Int.random(in: 500...5000),
                rank: index + 1,
                category: category
            )
        }

        // Include the current user in friend scope for better social feedback loops.
        friends.append(
            LeaderboardEntry(
                userId: UUID(),
                username: "you_creator",
                score: Int.random(in: 700...5200),
                rank: 0,
                category: category
            )
        )

        return friends
            .sorted { $0.score > $1.score }
            .enumerated()
            .map { index, entry in
                LeaderboardEntry(
                    id: entry.id,
                    userId: entry.userId,
                    username: entry.username,
                    score: entry.score,
                    rank: index + 1,
                    category: entry.category
                )
            }
    }
}
