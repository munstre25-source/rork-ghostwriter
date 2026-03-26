import Foundation
import SwiftUI

public struct OnboardingFeature {
    public static let views = OnboardingViews.self
    public static let services = OnboardingServices.self
}

public enum OnboardingViews {
    public static func onboardingView() -> some View {
        OnboardingView()
    }
}

public enum OnboardingServices {
    public static func makeOnboardingService() -> OnboardingService {
        OnboardingService()
    }
}
