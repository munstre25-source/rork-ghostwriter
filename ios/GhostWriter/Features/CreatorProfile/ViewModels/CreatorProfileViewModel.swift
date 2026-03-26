import SwiftUI
import Foundation

@Observable
final class CreatorProfileViewModel: @unchecked Sendable {
    var profile: CreatorProfile?
    var stats: CreatorStats?
    var recentClips: [GhostClip] = []
    var createdPersonalities: [GhostPersonality] = []
    var isLoading: Bool = false
    var isCurrentUser: Bool = true
    var isFollowing: Bool = false

    func loadProfile(userId: UUID? = nil) async {
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(for: .seconds(0.5))

        let id = userId ?? UUID()
        isCurrentUser = userId == nil

        profile = CreatorProfile(
            userId: id,
            username: isCurrentUser ? "you_creator" : "creator_\(id.uuidString.prefix(4))"
        )
        profile?.bio = "Creative thinker. Writer. Builder of ideas."
        profile?.followerCount = Int.random(in: 100...10000)
        profile?.followingCount = Int.random(in: 50...500)
        profile?.totalClipViews = Int.random(in: 1000...50000)
        profile?.totalEarnings = Double.random(in: 10...500)
        profile?.totalSessionsCreated = Int.random(in: 20...200)
        profile?.badges = ["First Spark", "Streak Champion", "Collaboration Master"]

        await loadStats()
        await loadRecentClips()
    }

    func loadStats() async {
        try? await Task.sleep(for: .seconds(0.3))
        stats = CreatorStats(
            totalSessions: Int.random(in: 50...300),
            totalWords: Int.random(in: 10000...100000),
            totalIdeas: Int.random(in: 100...1000),
            averageFlowScore: Double.random(in: 55...90),
            totalEarnings: profile?.totalEarnings ?? 0,
            totalClipViews: profile?.totalClipViews ?? 0,
            mostUsedPersonality: "The Muse",
            currentStreak: Int.random(in: 0...30),
            longestStreak: Int.random(in: 10...60)
        )
    }

    private func loadRecentClips() async {
        recentClips = (0..<4).map { i in
            let clip = GhostClip(
                sessionId: UUID(),
                creatorId: profile?.userId ?? UUID(),
                videoURL: URL(string: "https://ghostwriter.app/clip/\(i)")!,
                duration: Double.random(in: 10...30)
            )
            clip.title = ["Flow State", "Late Night", "Brainstorm", "Design Sprint"][i]
            clip.viewCount = Int.random(in: 100...5000)
            clip.likeCount = Int.random(in: 10...500)
            return clip
        }
    }

    func updateBio(_ bio: String) async throws {
        try await Task.sleep(for: .seconds(0.3))
        profile?.bio = bio
    }

    func toggleFollow() async throws {
        try await Task.sleep(for: .seconds(0.3))
        isFollowing.toggle()
        if isFollowing {
            profile?.followerCount += 1
        } else {
            profile?.followerCount = max(0, (profile?.followerCount ?? 1) - 1)
        }
    }
}
