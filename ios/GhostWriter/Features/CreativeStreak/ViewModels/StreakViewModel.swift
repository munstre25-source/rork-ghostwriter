import Foundation
import Observation

@Observable
final class StreakViewModel {

    var currentStreak: CreativeStreak?
    var activeChallenge: WeeklyChallenge?
    var isLoading: Bool = false
    var streakCalendarDates: [Date] = []
    var error: Error?
    var hasJoinedChallenge: Bool = false

    private let service: StreakService
    private let userId = UUID()

    init(service: StreakService = StreakService()) {
        self.service = service
    }

    func loadStreak() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.loadStreak(for: userId)
            currentStreak = service.currentStreak
            generateCalendarDates()
        } catch {
            self.error = error
        }
    }

    func loadActiveChallenge() async {
        do {
            activeChallenge = try await service.loadActiveChallenge()
        } catch {
            self.error = error
        }
    }

    func joinChallenge() async throws {
        guard let challenge = activeChallenge else { return }
        try await service.joinChallenge(challenge)
        hasJoinedChallenge = true
        activeChallenge = service.activeChallenge
    }

    var streakPercentOfLongest: Double {
        guard let streak = currentStreak, streak.longestStreak > 0 else { return 0 }
        return Double(streak.currentStreak) / Double(streak.longestStreak)
    }

    var milestones: [(days: Int, label: String, icon: String, achieved: Bool)] {
        let current = currentStreak?.longestStreak ?? 0
        return [
            (7,   "Week Warrior",    "flame.fill",          current >= 7),
            (14,  "Fortnight Focus", "bolt.fill",           current >= 14),
            (30,  "Monthly Master",  "star.fill",           current >= 30),
            (60,  "Dual Moon",       "moon.stars.fill",     current >= 60),
            (100, "Centurion",       "crown.fill",          current >= 100),
            (365, "Year of Words",   "trophy.fill",         current >= 365),
        ]
    }

    private func generateCalendarDates() {
        guard let streak = currentStreak else { return }
        let calendar = Calendar.current
        var dates: [Date] = []
        let today = calendar.startOfDay(for: .now)

        for dayOffset in 0..<streak.currentStreak {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                dates.append(date)
            }
        }

        // Sprinkle a few additional random older dates for visual interest
        for _ in 0..<Int.random(in: 3...8) {
            let offset = Int.random(in: (streak.currentStreak + 1)...(streak.currentStreak + 15))
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                dates.append(date)
            }
        }

        streakCalendarDates = dates
    }
}
