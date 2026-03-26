import Foundation
import Observation

enum LeaderboardScope: String, CaseIterable, Identifiable {
    case global
    case friends

    var id: String { rawValue }

    var title: String {
        switch self {
        case .global: "Global"
        case .friends: "Friends"
        }
    }
}

@Observable
final class LeaderboardViewModel {

    var entries: [LeaderboardEntry] = []
    var selectedCategory: LeaderboardCategory = .mostViewed
    var selectedScope: LeaderboardScope = .global
    var isLoading: Bool = false
    var currentUserRank: Int?
    var error: Error?

    private let service: LeaderboardService

    init(service: LeaderboardService = LeaderboardService()) {
        self.service = service
    }

    func loadLeaderboard() async {
        isLoading = true
        defer { isLoading = false }

        do {
            switch selectedScope {
            case .global:
                try await service.loadLeaderboard(category: selectedCategory)
                entries = service.entries
                currentUserRank = Int.random(in: 4...25)
            case .friends:
                let friendEntries = try await service.loadFriendLeaderboard(category: selectedCategory)
                entries = friendEntries.sorted { $0.score > $1.score }
                currentUserRank = entries.first(where: { $0.username == "you_creator" })?.rank
            }
        } catch {
            self.error = error
        }
    }

    func switchCategory(_ category: LeaderboardCategory) async {
        selectedCategory = category
        await loadLeaderboard()
    }

    func switchScope(_ scope: LeaderboardScope) async {
        selectedScope = scope
        await loadLeaderboard()
    }

    var topThree: [LeaderboardEntry] {
        Array(entries.prefix(3))
    }

    var remaining: [LeaderboardEntry] {
        Array(entries.dropFirst(3))
    }

    func formattedScore(for entry: LeaderboardEntry) -> String {
        if entry.score >= 1_000_000 {
            return String(format: "%.1fM", Double(entry.score) / 1_000_000)
        } else if entry.score >= 1_000 {
            return String(format: "%.1fK", Double(entry.score) / 1_000)
        }
        return "\(entry.score)"
    }

    func categoryStatLabel() -> String {
        switch selectedCategory {
        case .mostViewed:         "views"
        case .topEarnings:        "earned"
        case .longestStreak:      "days"
        case .mostCollaborations: "collabs"
        case .weeklyChallenge:    "pts"
        }
    }
}
