import UIKit
import Observation

/// Provides haptic feedback for creative interactions and UI events.
///
/// Uses `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator`
/// to deliver tactile responses tuned to different creative contexts.
@Observable
final class HapticService: @unchecked Sendable {

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    /// Delivers a light tap haptic.
    func lightTap() {
        lightGenerator.impactOccurred()
    }

    /// Delivers a medium tap haptic.
    func mediumTap() {
        mediumGenerator.impactOccurred()
    }

    /// Delivers a heavy tap haptic.
    func heavyTap() {
        heavyGenerator.impactOccurred()
    }

    /// Delivers a success notification haptic.
    func successNotification() {
        notificationGenerator.notificationOccurred(.success)
    }

    /// Delivers an error notification haptic.
    func errorNotification() {
        notificationGenerator.notificationOccurred(.error)
    }

    /// Delivers a rhythmic pulse haptic indicating the user has entered a flow state.
    func flowStatePulse() {
        Task { @MainActor in
            for _ in 0..<3 {
                lightGenerator.impactOccurred(intensity: 0.6)
                try? await Task.sleep(for: .milliseconds(120))
            }
        }
    }

    /// Delivers a haptic scaled to the confidence level of a suggestion.
    ///
    /// High-confidence suggestions receive stronger feedback to draw attention.
    ///
    /// - Parameter confidence: A value from 0 to 1 indicating suggestion confidence.
    func suggestionAppeared(confidence: Double) {
        let clamped = min(max(confidence, 0), 1)

        switch clamped {
        case 0.8...1.0:
            heavyGenerator.impactOccurred(intensity: 1.0)
        case 0.5..<0.8:
            mediumGenerator.impactOccurred(intensity: CGFloat(clamped))
        default:
            lightGenerator.impactOccurred(intensity: CGFloat(max(clamped, 0.3)))
        }
    }

    /// Delivers a personality-specific haptic pattern.
    ///
    /// Each pattern string maps to a distinct rhythmic sequence.
    ///
    /// - Parameter pattern: The haptic pattern identifier from a ``GhostPersonality``.
    func personalityHaptic(pattern: String) {
        Task { @MainActor in
            switch pattern {
            case "gentle_wave":
                for intensity in stride(from: 0.3, through: 0.8, by: 0.1) {
                    lightGenerator.impactOccurred(intensity: CGFloat(intensity))
                    try? await Task.sleep(for: .milliseconds(100))
                }
            case "steady_pulse":
                for _ in 0..<4 {
                    mediumGenerator.impactOccurred(intensity: 0.7)
                    try? await Task.sleep(for: .milliseconds(200))
                }
            case "sharp_tap":
                heavyGenerator.impactOccurred(intensity: 1.0)
                try? await Task.sleep(for: .milliseconds(80))
                heavyGenerator.impactOccurred(intensity: 0.5)
            case "rising_crescendo":
                for i in 1...5 {
                    mediumGenerator.impactOccurred(intensity: CGFloat(Double(i) / 5.0))
                    try? await Task.sleep(for: .milliseconds(150))
                }
            case "even_rhythm":
                for _ in 0..<3 {
                    mediumGenerator.impactOccurred(intensity: 0.5)
                    try? await Task.sleep(for: .milliseconds(250))
                }
            default:
                mediumGenerator.impactOccurred()
            }
        }
    }

    /// Delivers a subtle haptic indicating a remote collaborator is typing.
    func collaboratorTyping() {
        lightGenerator.impactOccurred(intensity: 0.3)
    }
}
