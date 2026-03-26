import Foundation
import SwiftUI

public struct GhostPersonalityFeature {
    public static let views = GhostPersonalityViews.self
    public static let services = GhostPersonalityServices.self
}

public enum GhostPersonalityViews {
    public static func personalityEditorView() -> some View {
        PersonalityEditorView()
    }

    public static func personalityMarketplaceView() -> some View {
        PersonalityMarketplaceView()
    }
}

public enum GhostPersonalityServices {
    public static func makePersonalityService() -> PersonalityService {
        PersonalityService()
    }
}

public typealias Personality = GhostPersonality
public typealias Trait = PersonalityTrait
