import Foundation
import SwiftUI

public struct LiveJamFeature {
    public static let views = LiveJamViews.self
    public static let services = LiveJamServices.self
}

public enum LiveJamViews {
    public static func liveJamView() -> some View {
        LiveJamView()
    }
}

public enum LiveJamServices {
    public static func makeSharePlayService() -> SharePlayService {
        SharePlayService()
    }
}

public typealias JamSession = LiveJamSession
