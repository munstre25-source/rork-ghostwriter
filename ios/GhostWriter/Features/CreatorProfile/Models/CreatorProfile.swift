import Foundation
import SwiftData

/// A creator's public profile containing identity, social stats, and marketplace data.
@Model
final class CreatorProfile: @unchecked Sendable {

    /// Unique identifier for this profile.
    @Attribute(.unique) var id: UUID

    /// The user account this profile belongs to.
    var userId: UUID

    /// The creator's unique display name.
    var username: String

    /// A short bio, if provided.
    var bio: String?

    /// URL of the creator's profile image, if set.
    var profileImageURL: URL?

    /// Number of followers.
    var followerCount: Int

    /// Number of accounts this creator follows.
    var followingCount: Int

    /// Lifetime total views across all clips.
    var totalClipViews: Int

    /// Lifetime total likes across all clips.
    var totalClipLikes: Int

    /// Lifetime total earnings in USD.
    var totalEarnings: Double

    /// Total number of sessions this creator has started.
    var totalSessionsCreated: Int

    /// IDs of personalities the creator has favorited.
    var favoritePersonalities: [UUID]

    /// Badge identifiers the creator has earned.
    var badges: [String]

    /// Whether this creator has been verified.
    var isVerified: Bool

    /// External social media links keyed by platform name.
    var socialLinks: [String: String]

    /// IDs of personalities this creator has published.
    var createdPersonalities: [UUID]

    /// IDs of sessions this creator has made public.
    var publicSessions: [UUID]

    /// Creates a new creator profile.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - userId: The owning user account ID.
    ///   - username: Display name.
    ///   - bio: Short bio text.
    ///   - profileImageURL: Profile image URL.
    ///   - followerCount: Follower count. Defaults to `0`.
    ///   - followingCount: Following count. Defaults to `0`.
    ///   - totalClipViews: Lifetime clip views. Defaults to `0`.
    ///   - totalClipLikes: Lifetime clip likes. Defaults to `0`.
    ///   - totalEarnings: Lifetime earnings. Defaults to `0`.
    ///   - totalSessionsCreated: Total sessions started. Defaults to `0`.
    ///   - favoritePersonalities: Favorited personality IDs. Defaults to empty.
    ///   - badges: Earned badge identifiers. Defaults to empty.
    ///   - isVerified: Verified status. Defaults to `false`.
    ///   - socialLinks: Social media links. Defaults to empty.
    ///   - createdPersonalities: Published personality IDs. Defaults to empty.
    ///   - publicSessions: Public session IDs. Defaults to empty.
    init(
        id: UUID = UUID(),
        userId: UUID,
        username: String,
        bio: String? = nil,
        profileImageURL: URL? = nil,
        followerCount: Int = 0,
        followingCount: Int = 0,
        totalClipViews: Int = 0,
        totalClipLikes: Int = 0,
        totalEarnings: Double = 0,
        totalSessionsCreated: Int = 0,
        favoritePersonalities: [UUID] = [],
        badges: [String] = [],
        isVerified: Bool = false,
        socialLinks: [String: String] = [:],
        createdPersonalities: [UUID] = [],
        publicSessions: [UUID] = []
    ) {
        self.id = id
        self.userId = userId
        self.username = username
        self.bio = bio
        self.profileImageURL = profileImageURL
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.totalClipViews = totalClipViews
        self.totalClipLikes = totalClipLikes
        self.totalEarnings = totalEarnings
        self.totalSessionsCreated = totalSessionsCreated
        self.favoritePersonalities = favoritePersonalities
        self.badges = badges
        self.isVerified = isVerified
        self.socialLinks = socialLinks
        self.createdPersonalities = createdPersonalities
        self.publicSessions = publicSessions
    }
}
