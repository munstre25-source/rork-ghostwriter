import Foundation
import Observation

// MARK: - ProfileError

/// Errors that can occur during profile operations.
enum ProfileError: Error, LocalizedError, Sendable {
    case loadFailed
    case updateFailed
    case followFailed
    case unfollowFailed
    case notFound
    case alreadyFollowing

    var errorDescription: String? {
        switch self {
        case .loadFailed:       "Failed to load creator profile."
        case .updateFailed:     "Failed to update profile."
        case .followFailed:     "Failed to follow creator."
        case .unfollowFailed:   "Failed to unfollow creator."
        case .notFound:         "Creator profile not found."
        case .alreadyFollowing: "You are already following this creator."
        }
    }
}

// MARK: - ProfileService

/// Manages creator profile loading, updating, and social interactions.
@Observable
final class ProfileService: @unchecked Sendable {

    /// The authenticated user's profile, if loaded.
    var currentProfile: CreatorProfile?

    /// Loads a creator profile by user ID.
    ///
    /// - Parameter userId: The user ID to load the profile for.
    /// - Returns: The loaded ``CreatorProfile``.
    /// - Throws: ``ProfileError/loadFailed`` if the profile cannot be loaded.
    func loadProfile(for userId: UUID) async throws -> CreatorProfile {
        try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))

        let profile = CreatorProfile(
            userId: userId,
            username: "creator_\(userId.uuidString.prefix(8))",
            bio: "Creative writer exploring the intersection of AI and storytelling.",
            followerCount: Int.random(in: 10...5000),
            followingCount: Int.random(in: 5...500),
            totalClipViews: Int.random(in: 100...50000),
            totalClipLikes: Int.random(in: 10...5000),
            totalEarnings: Double.random(in: 0...1000),
            totalSessionsCreated: Int.random(in: 5...200),
            badges: ["early_adopter", "streak_7"],
            isVerified: Bool.random()
        )

        currentProfile = profile
        return profile
    }

    /// Updates the current user's profile.
    ///
    /// - Parameter profile: The profile with updated fields.
    /// - Throws: ``ProfileError/updateFailed`` if the update fails.
    func updateProfile(_ profile: CreatorProfile) async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 0.3...1.0)))

        currentProfile = profile
        print("[Profile] Updated profile for \(profile.username)")
    }

    /// Follows a creator.
    ///
    /// - Parameter creatorId: The user ID of the creator to follow.
    /// - Throws: ``ProfileError/followFailed`` if the operation fails.
    func followCreator(_ creatorId: UUID) async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 0.3...0.8)))

        if let profile = currentProfile {
            profile.followingCount += 1
        }

        print("[Profile] Followed creator \(creatorId)")
    }

    /// Unfollows a creator.
    ///
    /// - Parameter creatorId: The user ID of the creator to unfollow.
    /// - Throws: ``ProfileError/unfollowFailed`` if the operation fails.
    func unfollowCreator(_ creatorId: UUID) async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 0.3...0.8)))

        if let profile = currentProfile {
            profile.followingCount = max(profile.followingCount - 1, 0)
        }

        print("[Profile] Unfollowed creator \(creatorId)")
    }
}
