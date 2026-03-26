import Foundation

/// Steps in the first-launch onboarding flow.
///
/// Each case represents a screen the user progresses through.
/// Use ``progress`` to drive a progress bar across the flow.
enum OnboardingStep: String, CaseIterable, Identifiable, Sendable {

    /// Welcome screen introducing the app.
    case welcome

    /// Personality quiz to match the user with a ghost.
    case personalityQuiz

    /// Guided first creative session.
    case firstSession

    /// First AI suggestion ("spark") moment.
    case firstSpark

    /// Introduction to monetization features.
    case monetizationMoment

    /// Social proof showing community activity.
    case socialProof

    /// Onboarding complete — transition to the main app.
    case complete

    /// Stable identity derived from the raw value.
    var id: String { rawValue }

    /// The headline displayed on this onboarding screen.
    var title: String {
        switch self {
        case .welcome:            "Welcome to GhostWriter"
        case .personalityQuiz:    "Find Your Ghost"
        case .firstSession:       "Your First Session"
        case .firstSpark:         "Feel the Spark"
        case .monetizationMoment: "Turn Creativity into Income"
        case .socialProof:        "Join the Community"
        case .complete:           "You're All Set!"
        }
    }

    /// Supporting text displayed below the title.
    var subtitle: String {
        switch self {
        case .welcome:            "Where creativity meets AI-powered inspiration."
        case .personalityQuiz:    "Answer a few questions to discover your ideal creative companion."
        case .firstSession:       "Start a quick session and see GhostWriter in action."
        case .firstSpark:         "Experience your first AI-generated suggestion."
        case .monetizationMoment: "Share clips, sell personalities, and earn from your creativity."
        case .socialProof:        "Thousands of creators are already writing with their ghosts."
        case .complete:           "Your ghost is ready. Let's create something amazing."
        }
    }

    /// An SF Symbol name used as the step's illustration.
    var imageName: String {
        switch self {
        case .welcome:            "hand.wave.fill"
        case .personalityQuiz:    "theatermasks.fill"
        case .firstSession:       "pencil.and.outline"
        case .firstSpark:         "sparkles"
        case .monetizationMoment: "dollarsign.circle.fill"
        case .socialProof:        "person.3.fill"
        case .complete:           "checkmark.seal.fill"
        }
    }

    /// Completion progress from 0 (start) to 1 (finish).
    var progress: Double {
        guard let index = Self.allCases.firstIndex(of: self) else { return 0 }
        return Double(index) / Double(Self.allCases.count - 1)
    }
}
