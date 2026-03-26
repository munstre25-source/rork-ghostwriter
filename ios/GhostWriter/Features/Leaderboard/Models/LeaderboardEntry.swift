import Foundation

// MARK: - LeaderboardCategory

/// Categories available on the leaderboard.
enum LeaderboardCategory: String, Codable, Hashable, CaseIterable, Identifiable, Sendable {

    /// Ranked by total clip views.
    case mostViewed

    /// Ranked by total earnings.
    case topEarnings

    /// Ranked by longest creative streak.
    case longestStreak

    /// Ranked by number of collaborations.
    case mostCollaborations

    /// Ranked by weekly challenge performance.
    case weeklyChallenge

    /// Stable identity derived from the raw value.
    var id: String { rawValue }

    /// A human-readable name for display in the UI.
    var displayName: String {
        switch self {
        case .mostViewed:          "Most Viewed"
        case .topEarnings:         "Top Earnings"
        case .longestStreak:       "Longest Streak"
        case .mostCollaborations:  "Most Collaborations"
        case .weeklyChallenge:     "Weekly Challenge"
        }
    }

    /// An SF Symbol name representing this category.
    var icon: String {
        switch self {
        case .mostViewed:          "eye.fill"
        case .topEarnings:         "dollarsign.circle.fill"
        case .longestStreak:       "flame.fill"
        case .mostCollaborations:  "person.3.fill"
        case .weeklyChallenge:     "trophy.fill"
        }
    }
}

// MARK: - LeaderboardEntry

/// A single entry on the leaderboard representing a ranked creator.
struct LeaderboardEntry: Identifiable, Codable, Hashable, Sendable {

    /// Unique identifier for this entry.
    var id: UUID

    /// The ranked user's ID.
    var userId: UUID

    /// The ranked user's display name.
    var username: String

    /// URL of the user's profile image, if available.
    var profileImageURL: URL?

    /// The user's score in the relevant category.
    var score: Int

    /// The user's rank position (1-based).
    var rank: Int

    /// The leaderboard category this entry belongs to.
    var category: LeaderboardCategory

    /// Creates a new leaderboard entry.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - userId: The ranked user's ID.
    ///   - username: Display name.
    ///   - profileImageURL: Profile image URL.
    ///   - score: Score in this category.
    ///   - rank: Rank position.
    ///   - category: The leaderboard category.
    init(
        id: UUID = UUID(),
        userId: UUID,
        username: String,
        profileImageURL: URL? = nil,
        score: Int,
        rank: Int,
        category: LeaderboardCategory
    ) {
        self.id = id
        self.userId = userId
        self.username = username
        self.profileImageURL = profileImageURL
        self.score = score
        self.rank = rank
        self.category = category
    }
}
