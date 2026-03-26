import Foundation
import SwiftData

/// A short video clip captured from a creative session.
///
/// Ghost clips are shareable, monetizable video recordings that showcase
/// highlights of a user's creative process.
@Model
final class GhostClip: @unchecked Sendable {

    /// Unique identifier for this clip.
    @Attribute(.unique) var id: UUID

    /// The session from which this clip was captured.
    var sessionId: UUID

    /// The user who created this clip.
    var creatorId: UUID

    /// Remote URL of the video file.
    var videoURL: URL

    /// Duration of the clip in seconds.
    var duration: Double

    /// Remote URL of the thumbnail image, if available.
    var thumbnailURL: URL?

    /// Optional user-provided title.
    var title: String?

    /// Optional user-provided description of the clip.
    var clipDescription: String?

    /// When this clip was created.
    var createdAt: Date

    /// Number of times this clip has been shared.
    var shareCount: Int

    /// Number of times this clip has been viewed.
    var viewCount: Int

    /// Number of likes this clip has received.
    var likeCount: Int

    /// Number of times this clip has been saved by other users.
    var saveCount: Int

    /// Whether this clip generates CPM-based revenue.
    var isMonetized: Bool

    /// Revenue earned from CPM-based advertising on this clip.
    var cpmRevenue: Double

    /// Whether this clip is publicly visible.
    var isPublic: Bool

    /// Display name of the personality used during the session.
    var personalityUsed: String

    /// Creates a new ghost clip.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - sessionId: The source session's ID.
    ///   - creatorId: The creator's user ID.
    ///   - videoURL: URL of the video file.
    ///   - duration: Clip duration in seconds. Defaults to `0`.
    ///   - thumbnailURL: Thumbnail URL, if available.
    ///   - title: Optional title.
    ///   - clipDescription: Optional description.
    ///   - createdAt: Creation date. Defaults to now.
    ///   - shareCount: Initial share count. Defaults to `0`.
    ///   - viewCount: Initial view count. Defaults to `0`.
    ///   - likeCount: Initial like count. Defaults to `0`.
    ///   - saveCount: Initial save count. Defaults to `0`.
    ///   - isMonetized: Monetization state. Defaults to `false`.
    ///   - cpmRevenue: CPM revenue earned. Defaults to `0`.
    ///   - isPublic: Public visibility. Defaults to `true`.
    ///   - personalityUsed: Name of the personality used. Defaults to `"The Muse"`.
    init(
        id: UUID = UUID(),
        sessionId: UUID,
        creatorId: UUID,
        videoURL: URL,
        duration: Double = 0,
        thumbnailURL: URL? = nil,
        title: String? = nil,
        clipDescription: String? = nil,
        createdAt: Date = .now,
        shareCount: Int = 0,
        viewCount: Int = 0,
        likeCount: Int = 0,
        saveCount: Int = 0,
        isMonetized: Bool = false,
        cpmRevenue: Double = 0,
        isPublic: Bool = true,
        personalityUsed: String = "The Muse"
    ) {
        self.id = id
        self.sessionId = sessionId
        self.creatorId = creatorId
        self.videoURL = videoURL
        self.duration = duration
        self.thumbnailURL = thumbnailURL
        self.title = title
        self.clipDescription = clipDescription
        self.createdAt = createdAt
        self.shareCount = shareCount
        self.viewCount = viewCount
        self.likeCount = likeCount
        self.saveCount = saveCount
        self.isMonetized = isMonetized
        self.cpmRevenue = cpmRevenue
        self.isPublic = isPublic
        self.personalityUsed = personalityUsed
    }
}
