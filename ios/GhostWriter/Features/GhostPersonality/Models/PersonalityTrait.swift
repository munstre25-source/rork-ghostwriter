import Foundation

/// A trait that characterizes a ``GhostPersonality``'s creative style.
enum PersonalityTrait: String, Codable, Hashable, CaseIterable, Sendable {

    /// Provides positive reinforcement and support.
    case encouraging

    /// Offers honest, constructive criticism.
    case critical

    /// Focuses on logic and systematic analysis.
    case analytical

    /// Uses humor and lightness to inspire creativity.
    case playful

    /// Emphasizes outlines, frameworks, and organization.
    case structured

    /// Embraces spontaneity and unstructured exploration.
    case freeform

    /// Favors brevity and precision.
    case concise

    /// Favors rich detail and extended elaboration.
    case verbose

    /// Uses professional, polished language.
    case formal

    /// Uses conversational, relaxed language.
    case casual

    /// A human-readable label for display in the UI.
    var displayName: String {
        switch self {
        case .encouraging: "Encouraging"
        case .critical:    "Critical"
        case .analytical:  "Analytical"
        case .playful:     "Playful"
        case .structured:  "Structured"
        case .freeform:    "Freeform"
        case .concise:     "Concise"
        case .verbose:     "Verbose"
        case .formal:      "Formal"
        case .casual:      "Casual"
        }
    }
}
