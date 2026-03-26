import Foundation
import Observation

// MARK: - DiscoveryError

/// Errors that can occur during discovery feed operations.
enum DiscoveryError: Error, LocalizedError, Sendable {
    case feedLoadFailed
    case searchFailed
    case trendingLoadFailed

    var errorDescription: String? {
        switch self {
        case .feedLoadFailed:       "Failed to load the discovery feed."
        case .searchFailed:         "Search failed."
        case .trendingLoadFailed:   "Failed to load trending content."
        }
    }
}

// MARK: - DiscoveryService

/// Manages the discovery feed, search, and trending content.
@Observable
final class DiscoveryService: @unchecked Sendable {

    /// Items currently displayed in the discovery feed.
    var feedItems: [DiscoveryItem] = []

    /// Personalities that are currently trending.
    var trendingPersonalities: [GhostPersonality] = []

    /// Public sessions visible in the feed.
    var publicSessions: [CreativeSession] = []

    /// Loads the discovery feed with mixed content types.
    ///
    /// - Throws: ``DiscoveryError/feedLoadFailed`` if the feed cannot be loaded.
    func loadFeed() async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))

        let creatorId = UUID()
        feedItems = [
            DiscoveryItem(
                type: .trendingSession,
                title: "Late Night Poetry Flow",
                subtitle: "A mesmerizing 45-minute writing session",
                creatorName: "luna_writes",
                creatorId: creatorId,
                personalityName: "The Muse",
                viewCount: Int.random(in: 500...5000),
                likeCount: Int.random(in: 50...500)
            ),
            DiscoveryItem(
                type: .trendingPersonality,
                title: "The Philosopher",
                subtitle: "Deep-thinking personality for existential exploration",
                creatorName: "mind_architect",
                creatorId: UUID(),
                viewCount: Int.random(in: 1000...10000),
                likeCount: Int.random(in: 200...2000)
            ),
            DiscoveryItem(
                type: .featuredCreator,
                title: "Writer of the Week",
                subtitle: "Consistently producing stunning creative sessions",
                creatorName: "creative_storm",
                creatorId: UUID(),
                viewCount: Int.random(in: 2000...20000),
                likeCount: Int.random(in: 500...5000)
            ),
            DiscoveryItem(
                type: .weeklyChallenge,
                title: "100 Words in 10 Minutes",
                subtitle: "Speed-writing challenge with The Critic",
                creatorName: "GhostWriter Team",
                creatorId: UUID(),
                viewCount: Int.random(in: 3000...15000),
                likeCount: Int.random(in: 800...4000)
            ),
            DiscoveryItem(
                type: .popularClip,
                title: "The Moment Inspiration Struck",
                subtitle: "Watch the AI spark a brilliant plot twist",
                creatorName: "story_weaver",
                creatorId: UUID(),
                personalityName: "The Visionary",
                viewCount: Int.random(in: 5000...50000),
                likeCount: Int.random(in: 1000...10000)
            )
        ]
    }

    /// Searches the discovery feed by query string.
    ///
    /// - Parameter query: The search query.
    /// - Returns: Matching ``DiscoveryItem`` results.
    /// - Throws: ``DiscoveryError/searchFailed`` if the search fails.
    func search(query: String) async throws -> [DiscoveryItem] {
        try await Task.sleep(for: .seconds(Double.random(in: 0.3...1.0)))

        let lowered = query.lowercased()
        return feedItems.filter {
            $0.title.lowercased().contains(lowered) ||
            $0.subtitle.lowercased().contains(lowered) ||
            $0.creatorName.lowercased().contains(lowered)
        }
    }

    /// Loads trending personalities and public sessions.
    ///
    /// - Throws: ``DiscoveryError/trendingLoadFailed`` if trending data cannot be loaded.
    func loadTrending() async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))

        trendingPersonalities = [
            .theMuse(),
            .theVisionary(),
            .theCritic()
        ]

        publicSessions = (0..<5).map { i in
            CreativeSession(
                userId: UUID(),
                title: "Trending Session \(i + 1)",
                type: SessionType.allCases.randomElement() ?? .writing,
                isLive: i < 2,
                isPublic: true,
                personalityId: UUID(),
                wordCount: Int.random(in: 100...2000),
                flowScore: Double.random(in: 40...95)
            )
        }
    }
}
