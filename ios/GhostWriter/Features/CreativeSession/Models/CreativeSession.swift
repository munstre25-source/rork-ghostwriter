import Foundation
import SwiftData

/// A creative session representing a timed writing or brainstorming activity.
///
/// `CreativeSession` captures all metadata about a user's creative work period,
/// including input logs, flow metrics, collaboration details, and monetization state.
@Model
final class CreativeSession: @unchecked Sendable {

    /// Unique identifier for this session.
    @Attribute(.unique) var id: UUID

    /// The user who owns this session.
    var userId: UUID

    /// When the session began.
    var startTime: Date

    /// When the session ended, or `nil` if still in progress.
    var endTime: Date?

    /// Optional user-provided title for the session.
    var title: String?

    /// The creative activity type for this session.
    var type: SessionType

    /// Chronological log of raw user inputs captured during the session.
    var rawInputLog: [String]

    /// Whether the session is currently live.
    var isLive: Bool

    /// Whether the session is publicly visible.
    var isPublic: Bool

    /// The ghost personality driving AI suggestions in this session.
    var personalityId: UUID

    /// User IDs of collaborators participating in this session.
    var collaboratorIds: [UUID]

    /// Total number of words written during the session.
    var wordCount: Int

    /// Total number of ideas generated during the session.
    var ideaCount: Int

    /// A score from 0 to 100 representing the user's creative flow state.
    var flowScore: Double

    /// AI-detected mood during the session, if available.
    var moodDetected: String?

    /// IDs of ``GhostClip`` instances created from this session.
    var createdClipIds: [UUID]

    /// User IDs who bookmarked this session.
    var bookmarkedBy: [UUID]

    /// Whether this session generates revenue.
    var isMonetized: Bool

    /// Creates a new creative session with sensible defaults.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - userId: The owning user's ID.
    ///   - startTime: Session start time. Defaults to now.
    ///   - endTime: Session end time, or `nil` if still active.
    ///   - title: Optional session title.
    ///   - type: The session activity type. Defaults to `.writing`.
    ///   - rawInputLog: Initial input log entries. Defaults to empty.
    ///   - isLive: Whether the session is live. Defaults to `true`.
    ///   - isPublic: Whether the session is publicly visible. Defaults to `false`.
    ///   - personalityId: The ghost personality ID.
    ///   - collaboratorIds: Collaborator user IDs. Defaults to empty.
    ///   - wordCount: Initial word count. Defaults to `0`.
    ///   - ideaCount: Initial idea count. Defaults to `0`.
    ///   - flowScore: Initial flow score. Defaults to `0`.
    ///   - moodDetected: Detected mood string, if any.
    ///   - createdClipIds: Clip IDs created from this session. Defaults to empty.
    ///   - bookmarkedBy: Users who bookmarked this session. Defaults to empty.
    ///   - isMonetized: Whether the session is monetized. Defaults to `false`.
    init(
        id: UUID = UUID(),
        userId: UUID,
        startTime: Date = .now,
        endTime: Date? = nil,
        title: String? = nil,
        type: SessionType = .writing,
        rawInputLog: [String] = [],
        isLive: Bool = true,
        isPublic: Bool = false,
        personalityId: UUID,
        collaboratorIds: [UUID] = [],
        wordCount: Int = 0,
        ideaCount: Int = 0,
        flowScore: Double = 0,
        moodDetected: String? = nil,
        createdClipIds: [UUID] = [],
        bookmarkedBy: [UUID] = [],
        isMonetized: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.startTime = startTime
        self.endTime = endTime
        self.title = title
        self.type = type
        self.rawInputLog = rawInputLog
        self.isLive = isLive
        self.isPublic = isPublic
        self.personalityId = personalityId
        self.collaboratorIds = collaboratorIds
        self.wordCount = wordCount
        self.ideaCount = ideaCount
        self.flowScore = min(max(flowScore, 0), 100)
        self.moodDetected = moodDetected
        self.createdClipIds = createdClipIds
        self.bookmarkedBy = bookmarkedBy
        self.isMonetized = isMonetized
    }
}
