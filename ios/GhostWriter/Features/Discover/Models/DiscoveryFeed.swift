import Foundation

// MARK: - DiscoveryItemType

/// The kind of content surfaced in the discovery feed.
enum DiscoveryItemType: String, Codable, Hashable, CaseIterable, Identifiable, Sendable {

    /// A creative session that is currently trending.
    case trendingSession

    /// A ghost personality that is currently trending.
    case trendingPersonality

    /// A creator highlighted by the editorial team.
    case featuredCreator

    /// The current weekly challenge.
    case weeklyChallenge

    /// A clip with high engagement.
    case popularClip

    /// Stable identity derived from the raw value.
    var id: String { rawValue }

    /// A human-readable label for display in the UI.
    var displayName: String {
        switch self {
        case .trendingSession:     "Trending Session"
        case .trendingPersonality: "Trending Personality"
        case .featuredCreator:     "Featured Creator"
        case .weeklyChallenge:     "Weekly Challenge"
        case .popularClip:         "Popular Clip"
        }
    }

    /// An SF Symbol name representing this item type.
    var icon: String {
        switch self {
        case .trendingSession:     "chart.line.uptrend.xyaxis"
        case .trendingPersonality: "theatermasks.fill"
        case .featuredCreator:     "star.fill"
        case .weeklyChallenge:     "trophy.fill"
        case .popularClip:         "play.rectangle.fill"
        }
    }
}

// MARK: - DiscoveryItem

/// A single item displayed in the discovery feed.
struct DiscoveryItem: Identifiable, Codable, Hashable, Sendable {

    /// Unique identifier for this discovery item.
    var id: UUID

    /// The kind of content this item represents.
    var type: DiscoveryItemType

    /// Primary display title.
    var title: String

    /// Secondary display text.
    var subtitle: String

    /// URL of the item's cover image, if available.
    var imageURL: URL?

    /// Display name of the content's creator.
    var creatorName: String

    /// The creator's user ID.
    var creatorId: UUID

    /// Name of the associated personality, if any.
    var personalityName: String?

    /// Number of views.
    var viewCount: Int

    /// Number of likes.
    var likeCount: Int

    /// Creates a new discovery item.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - type: The content type.
    ///   - title: Primary title.
    ///   - subtitle: Secondary text.
    ///   - imageURL: Cover image URL.
    ///   - creatorName: Creator's display name.
    ///   - creatorId: Creator's user ID.
    ///   - personalityName: Associated personality name.
    ///   - viewCount: View count. Defaults to `0`.
    ///   - likeCount: Like count. Defaults to `0`.
    init(
        id: UUID = UUID(),
        type: DiscoveryItemType,
        title: String,
        subtitle: String,
        imageURL: URL? = nil,
        creatorName: String,
        creatorId: UUID,
        personalityName: String? = nil,
        viewCount: Int = 0,
        likeCount: Int = 0
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.creatorName = creatorName
        self.creatorId = creatorId
        self.personalityName = personalityName
        self.viewCount = viewCount
        self.likeCount = likeCount
    }
}
