import SwiftUI
import Foundation

enum DiscoverFilter: String, CaseIterable, Identifiable {
    case all, sessions, personalities, creators, challenges

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: "All"
        case .sessions: "Sessions"
        case .personalities: "Personalities"
        case .creators: "Creators"
        case .challenges: "Challenges"
        }
    }

    var icon: String {
        switch self {
        case .all: "square.grid.2x2"
        case .sessions: "sparkles"
        case .personalities: "theatermasks"
        case .creators: "person.2"
        case .challenges: "trophy"
        }
    }
}

@Observable
final class DiscoverViewModel: @unchecked Sendable {
    var feedItems: [DiscoveryItem] = []
    var searchQuery: String = ""
    var isLoading: Bool = false
    var selectedFilter: DiscoverFilter = .all

    func loadFeed() async {
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(for: .seconds(0.5))

        feedItems = [
            DiscoveryItem(type: .trendingPersonality, title: "The Architect", subtitle: "Structured, analytical thinking partner", creatorName: "GhostWriter", personalityName: "The Architect", viewCount: 12500, likeCount: 890),
            DiscoveryItem(type: .trendingSession, title: "Building the Future of AI", subtitle: "A brainstorming session on next-gen tools", creatorName: "alex_creates", personalityName: "The Visionary", viewCount: 3400, likeCount: 230),
            DiscoveryItem(type: .featuredCreator, title: "maya_writes", subtitle: "Top creator this week — 50K+ words", creatorName: "maya_writes", viewCount: 8900, likeCount: 1200),
            DiscoveryItem(type: .weeklyChallenge, title: "500 Words Challenge", subtitle: "Write 500 words this week with The Muse", viewCount: 5600, likeCount: 340),
            DiscoveryItem(type: .popularClip, title: "That Aha! Moment", subtitle: "When the ghost nails the suggestion", creatorName: "code_ninja", personalityName: "The Critic", viewCount: 15000, likeCount: 2100),
            DiscoveryItem(type: .trendingPersonality, title: "The Muse", subtitle: "Encouraging, creative inspiration", creatorName: "GhostWriter", personalityName: "The Muse", viewCount: 25000, likeCount: 3400),
        ]
    }

    func search() async {
        guard !searchQuery.isEmpty else {
            await loadFeed()
            return
        }
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(for: .seconds(0.3))
        feedItems = feedItems.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery) ||
            ($0.subtitle ?? "").localizedCaseInsensitiveContains(searchQuery)
        }
    }

    func refresh() async {
        await loadFeed()
    }

    var filteredItems: [DiscoveryItem] {
        switch selectedFilter {
        case .all: return feedItems
        case .sessions: return feedItems.filter { $0.type == .trendingSession }
        case .personalities: return feedItems.filter { $0.type == .trendingPersonality }
        case .creators: return feedItems.filter { $0.type == .featuredCreator }
        case .challenges: return feedItems.filter { $0.type == .weeklyChallenge }
        }
    }
}
