import Foundation
import SwiftUI

public struct LeaderboardFeature {
    public static let views = LeaderboardViews.self
    public static let services = LeaderboardServices.self
}

public enum LeaderboardViews {
    public static func leaderboardView() -> some View {
        LeaderboardView()
    }
}

public enum LeaderboardServices {
    public static func makeLeaderboardService() -> LeaderboardService {
        LeaderboardService()
    }
}

public typealias Ranking = LeaderboardEntry
public typealias RankingCategory = LeaderboardCategory
