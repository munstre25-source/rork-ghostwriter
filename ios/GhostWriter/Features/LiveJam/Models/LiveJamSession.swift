import Foundation
import SwiftData

/// A real-time collaborative writing session between multiple creators.
///
/// A Live Jam session links to an underlying ``CreativeSession`` and adds
/// multiplayer-specific metadata such as collaboration scoring and shared suggestions.
@Model
final class LiveJamSession: @unchecked Sendable {

    /// Unique identifier for this Live Jam session.
    @Attribute(.unique) var id: UUID

    /// The user who started the Live Jam.
    var hostId: UUID

    /// User IDs of participants (excluding the host).
    var collaboratorIds: [UUID]

    /// The underlying creative session ID.
    var sessionId: UUID

    /// When the Live Jam began.
    var startTime: Date

    /// When the Live Jam ended, or `nil` if still in progress.
    var endTime: Date?

    /// A score representing the quality of collaboration (0–100).
    var collaborationScore: Double

    /// Total words written by all participants combined.
    var totalWordsWritten: Int

    /// Number of AI suggestions that were shared among participants.
    var sharedSuggestionCount: Int

    /// Whether the Live Jam is currently active.
    var isActive: Bool

    /// Creates a new Live Jam session.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - hostId: The host user's ID.
    ///   - collaboratorIds: Participant user IDs. Defaults to empty.
    ///   - sessionId: The underlying creative session ID.
    ///   - startTime: Start time. Defaults to now.
    ///   - endTime: End time, or `nil` if still active.
    ///   - collaborationScore: Collaboration quality score. Defaults to `0`.
    ///   - totalWordsWritten: Combined word count. Defaults to `0`.
    ///   - sharedSuggestionCount: Shared suggestions count. Defaults to `0`.
    ///   - isActive: Whether the session is active. Defaults to `true`.
    init(
        id: UUID = UUID(),
        hostId: UUID,
        collaboratorIds: [UUID] = [],
        sessionId: UUID,
        startTime: Date = .now,
        endTime: Date? = nil,
        collaborationScore: Double = 0,
        totalWordsWritten: Int = 0,
        sharedSuggestionCount: Int = 0,
        isActive: Bool = true
    ) {
        self.id = id
        self.hostId = hostId
        self.collaboratorIds = collaboratorIds
        self.sessionId = sessionId
        self.startTime = startTime
        self.endTime = endTime
        self.collaborationScore = min(max(collaborationScore, 0), 100)
        self.totalWordsWritten = totalWordsWritten
        self.sharedSuggestionCount = sharedSuggestionCount
        self.isActive = isActive
    }
}
