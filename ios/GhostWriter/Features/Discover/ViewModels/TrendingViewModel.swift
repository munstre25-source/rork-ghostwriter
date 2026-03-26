import SwiftUI
import Foundation

@Observable
final class TrendingViewModel: @unchecked Sendable {
    var trendingPersonalities: [GhostPersonality] = []
    var trendingClips: [GhostClip] = []
    var isLoading: Bool = false

    func loadTrending() async {
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(for: .seconds(0.5))

        trendingPersonalities = [
            GhostPersonality.theMuse(),
            GhostPersonality.theArchitect(),
            GhostPersonality.theCritic(),
            GhostPersonality.theVisionary(),
            GhostPersonality.theAnalyst()
        ]

        trendingClips = (0..<6).map { i in
            let clip = GhostClip(
                sessionId: UUID(),
                creatorId: UUID(),
                videoURL: URL(string: "https://ghostwriter.app/trending/\(i)")!,
                duration: Double.random(in: 10...30)
            )
            clip.title = ["Creative Burst", "Flow State", "Design Sprint", "Code Jam", "Late Night Ideas", "Brainstorm"][i]
            clip.viewCount = Int.random(in: 500...20000)
            clip.likeCount = Int.random(in: 50...2000)
            return clip
        }
    }
}
