import Foundation
import SwiftUI

public struct CreativeStreakFeature {
    public static let views = CreativeStreakViews.self
    public static let services = CreativeStreakServices.self
}

public enum CreativeStreakViews {
    public static func streakView() -> some View {
        StreakView()
    }
}

public enum CreativeStreakServices {
    public static func makeStreakService() -> StreakService {
        StreakService()
    }
}

public typealias Streak = CreativeStreak
