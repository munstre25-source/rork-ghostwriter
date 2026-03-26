import Foundation
import SwiftUI

public struct CreatorProfileFeature {
    public static let views = CreatorProfileViews.self
    public static let services = CreatorProfileServices.self
}

public enum CreatorProfileViews {
    public static func creatorProfileView() -> some View {
        CreatorProfileView()
    }

    public static func creatorStatsView() -> some View {
        CreatorStatsView()
    }

    public static func earningsView() -> some View {
        EarningsView()
    }
}

public enum CreatorProfileServices {
    public static func makeProfileService() -> ProfileService {
        ProfileService()
    }
}

public typealias Profile = CreatorProfile
public typealias Stats = CreatorStats
