import Foundation

/// Defines all backend API endpoints used by the GhostWriter client.
///
/// Each case carries its HTTP path, method, and default headers.
enum APIEndpoint: Sendable {

    // MARK: Sessions

    /// Lists all sessions for the authenticated user.
    case sessions
    /// Retrieves a single session by ID.
    case session(id: UUID)
    /// Creates a new creative session.
    case createSession
    /// Updates an existing session.
    case updateSession(id: UUID)
    /// Ends a session.
    case endSession(id: UUID)

    // MARK: Personalities

    /// Lists available ghost personalities.
    case personalities
    /// Retrieves a single personality by ID.
    case personality(id: UUID)
    /// Creates a custom personality.
    case createPersonality
    /// Publishes a personality to the marketplace.
    case publishPersonality(id: UUID)

    // MARK: Clips

    /// Lists clips for the authenticated user.
    case clips
    /// Retrieves a single clip by ID.
    case clip(id: UUID)
    /// Creates a new clip.
    case createClip
    /// Deletes a clip.
    case deleteClip(id: UUID)
    /// Shares a clip to an external platform.
    case shareClip(id: UUID)

    // MARK: Creators

    /// Retrieves a creator profile by user ID.
    case creator(userId: UUID)
    /// Updates the authenticated user's profile.
    case updateCreator
    /// Follows a creator.
    case followCreator(userId: UUID)
    /// Unfollows a creator.
    case unfollowCreator(userId: UUID)

    // MARK: Leaderboard

    /// Retrieves the leaderboard for a given category.
    case leaderboard(category: String)
    /// Retrieves the friends leaderboard.
    case friendLeaderboard

    // MARK: Challenges

    /// Lists active weekly challenges.
    case challenges
    /// Joins a specific challenge.
    case joinChallenge(id: UUID)

    // MARK: Discover

    /// Retrieves the discovery feed.
    case discover
    /// Searches discovery content.
    case discoverSearch(query: String)
    /// Retrieves trending content.
    case trending

    /// The URL path component for this endpoint.
    var path: String {
        switch self {
        case .sessions:                     "sessions"
        case .session(let id):              "sessions/\(id.uuidString)"
        case .createSession:                "sessions"
        case .updateSession(let id):        "sessions/\(id.uuidString)"
        case .endSession(let id):           "sessions/\(id.uuidString)/end"
        case .personalities:                "personalities"
        case .personality(let id):          "personalities/\(id.uuidString)"
        case .createPersonality:            "personalities"
        case .publishPersonality(let id):   "personalities/\(id.uuidString)/publish"
        case .clips:                        "clips"
        case .clip(let id):                 "clips/\(id.uuidString)"
        case .createClip:                   "clips"
        case .deleteClip(let id):           "clips/\(id.uuidString)"
        case .shareClip(let id):            "clips/\(id.uuidString)/share"
        case .creator(let userId):          "creators/\(userId.uuidString)"
        case .updateCreator:                "creators/me"
        case .followCreator(let userId):    "creators/\(userId.uuidString)/follow"
        case .unfollowCreator(let userId):  "creators/\(userId.uuidString)/unfollow"
        case .leaderboard(let category):    "leaderboard/\(category)"
        case .friendLeaderboard:            "leaderboard/friends"
        case .challenges:                   "challenges"
        case .joinChallenge(let id):        "challenges/\(id.uuidString)/join"
        case .discover:                     "discover"
        case .discoverSearch:               "discover/search"
        case .trending:                     "discover/trending"
        }
    }

    /// The HTTP method for this endpoint.
    var method: String {
        switch self {
        case .sessions, .session, .personalities, .personality,
             .clips, .clip, .creator, .leaderboard, .friendLeaderboard,
             .challenges, .discover, .discoverSearch, .trending:
            "GET"
        case .createSession, .createPersonality, .publishPersonality,
             .createClip, .shareClip, .followCreator, .joinChallenge:
            "POST"
        case .updateSession, .updateCreator:
            "PUT"
        case .deleteClip, .unfollowCreator, .endSession:
            "DELETE"
        }
    }

    /// Default HTTP headers for this endpoint.
    var headers: [String: String] {
        var base: [String: String] = [
            "X-API-Version": "1",
            "X-Client-Platform": "ios"
        ]

        switch self {
        case .discoverSearch(let query):
            base["X-Search-Query"] = query
        default:
            break
        }

        return base
    }
}
