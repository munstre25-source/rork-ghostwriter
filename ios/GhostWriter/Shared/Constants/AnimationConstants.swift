import SwiftUI

/// Animation timing, spring parameters, and transitions for GhostWriter.
struct AnimationConstants {
    // MARK: - Durations

    static let instantDuration: Double = 0.1
    static let quickDuration: Double = 0.2
    static let standardDuration: Double = 0.35
    static let slowDuration: Double = 0.6
    static let breathDuration: Double = 2.0

    // MARK: - Spring Parameters

    static let snappySpring: Animation = .spring(duration: 0.3, bounce: 0.2)
    static let gentleSpring: Animation = .spring(duration: 0.5, bounce: 0.3)
    static let bouncySpring: Animation = .spring(duration: 0.6, bounce: 0.5)

    // MARK: - Easing

    static let standardEase: Animation = .easeInOut(duration: standardDuration)
    static let quickEase: Animation = .easeOut(duration: quickDuration)

    // MARK: - Haptic Timing

    static let hapticDelay: Double = 0.05

    // MARK: - Debounce

    static let typingDebounce: Double = 0.5
    static let searchDebounce: Double = 0.3
    static let scrollDebounce: Double = 0.15

    // MARK: - Transitions

    static let fadeTransition: AnyTransition = .opacity.animation(.easeInOut(duration: standardDuration))
    static let slideUpTransition: AnyTransition = .move(edge: .bottom).combined(with: .opacity)
    static let scaleTransition: AnyTransition = .scale.combined(with: .opacity)
}
