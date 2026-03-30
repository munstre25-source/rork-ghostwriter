import Foundation
import Observation

@Observable
final class LeaderboardViewModel {

    var entries: [LeaderboardEntry] = []
    var selectedCategory: LeaderboardCategory = .mostViewed
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
            try await service.loadLeaderboard(category: selectedCategory)
            entries = service.entries
            currentUserRank = Int.random(in: 4...25)
        } catch {
            self.error = error
        }
    }

    func switchCategory(_ category: LeaderboardCategory) async {
        selectedCategory = category
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
