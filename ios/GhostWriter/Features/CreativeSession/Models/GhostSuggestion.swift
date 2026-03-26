import Foundation
import SwiftData

// MARK: - SuggestionType

/// The kind of AI suggestion offered during a creative session.
enum SuggestionType: String, Codable, Hashable, CaseIterable, Identifiable, Sendable {

    /// Continues the user's current line of thought.
    case continuation

    /// Challenges the user's assumptions or direction.
    case challenge

    /// Summarizes recent work.
    case summary

    /// Reframes the topic from a different angle.
    case reframe

    /// Expands on an existing idea with more detail.
    case expand

    /// Stable identity derived from the raw value.
    var id: String { rawValue }

    /// A human-readable label for display in the UI.
    var displayName: String {
        switch self {
        case .continuation: "Continuation"
        case .challenge:    "Challenge"
        case .summary:      "Summary"
        case .reframe:      "Reframe"
        case .expand:       "Expand"
        }
    }
}

// MARK: - GhostSuggestion

/// An AI-generated suggestion produced during a creative session.
///
/// Each suggestion is tied to a specific session and personality, and carries
/// the surrounding context so the user can understand why it was offered.
@Model
final class GhostSuggestion: @unchecked Sendable {

    /// Unique identifier for this suggestion.
    @Attribute(.unique) var id: UUID

    /// The session in which this suggestion was generated.
    var sessionId: UUID

    /// The personality that produced this suggestion.
    var personalityId: UUID

    /// The suggestion text content.
    var content: String

    /// The category of this suggestion.
    var type: SuggestionType

    /// AI confidence in the suggestion's relevance, from 0 (no confidence) to 1 (full confidence).
    var confidenceScore: Double

    /// Whether the user accepted the suggestion, or `nil` if not yet acted upon.
    var accepted: Bool?

    /// User's quick rating: -1 (dislike), 0 (neutral), or 1 (like). `nil` if unrated.
    var userRating: Int?

    /// When this suggestion was generated.
    var timestamp: Date

    /// The user's text immediately before the suggestion point.
    var contextBefore: String

    /// The user's text immediately after the suggestion point.
    var contextAfter: String

    /// Creates a new ghost suggestion.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - sessionId: The owning session's ID.
    ///   - personalityId: The generating personality's ID.
    ///   - content: The suggestion text.
    ///   - type: The suggestion category. Defaults to `.continuation`.
    ///   - confidenceScore: Confidence from 0 to 1. Defaults to `0.5`.
    ///   - accepted: Acceptance state. Defaults to `nil`.
    ///   - userRating: User rating. Defaults to `nil`.
    ///   - timestamp: Creation time. Defaults to now.
    ///   - contextBefore: Text before the suggestion point. Defaults to empty.
    ///   - contextAfter: Text after the suggestion point. Defaults to empty.
    init(
        id: UUID = UUID(),
        sessionId: UUID,
        personalityId: UUID,
        content: String,
        type: SuggestionType = .continuation,
        confidenceScore: Double = 0.5,
        accepted: Bool? = nil,
        userRating: Int? = nil,
        timestamp: Date = .now,
        contextBefore: String = "",
        contextAfter: String = ""
    ) {
        self.id = id
        self.sessionId = sessionId
        self.personalityId = personalityId
        self.content = content
        self.type = type
        self.confidenceScore = min(max(confidenceScore, 0), 1)
        self.accepted = accepted
        self.userRating = userRating
        self.timestamp = timestamp
        self.contextBefore = contextBefore
        self.contextAfter = contextAfter
    }
}
