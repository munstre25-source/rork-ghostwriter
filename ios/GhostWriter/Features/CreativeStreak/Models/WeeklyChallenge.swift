import Foundation
import SwiftData

/// A time-limited community challenge that encourages creative activity.
///
/// Weekly challenges can optionally require a specific personality, set word or session
/// count targets, and carry sponsor-backed prize pools.
@Model
final class WeeklyChallenge: @unchecked Sendable {

    /// Unique identifier for this challenge.
    @Attribute(.unique) var id: UUID

    /// Display title of the challenge.
    var title: String

    /// A detailed description of the challenge rules and goals.
    var challengeDescription: String

    /// The personality required for this challenge, or `nil` if any personality is allowed.
    var personalityRequired: UUID?

    /// Target word count to complete the challenge, if applicable.
    var targetWordCount: Int?

    /// Target session count to complete the challenge, if applicable.
    var targetSessionCount: Int?

    /// When the challenge opens for participation.
    var startDate: Date

    /// When the challenge closes.
    var endDate: Date

    /// Number of creators participating.
    var participantCount: Int

    /// The sponsoring entity's ID, if sponsored.
    var sponsorId: UUID?

    /// The sponsor's prize pool amount in USD, if sponsored.
    var sponsorAmount: Double?

    /// Whether the challenge is currently accepting participation.
    ///
    /// Derived from ``startDate`` and ``endDate`` relative to the current time.
    var isActive: Bool {
        let now = Date.now
        return now >= startDate && now <= endDate
    }

    /// Creates a new weekly challenge.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - title: Display title.
    ///   - challengeDescription: Challenge rules and goals.
    ///   - personalityRequired: Required personality ID, if any.
    ///   - targetWordCount: Word count target, if any.
    ///   - targetSessionCount: Session count target, if any.
    ///   - startDate: Challenge start date.
    ///   - endDate: Challenge end date.
    ///   - participantCount: Number of participants. Defaults to `0`.
    ///   - sponsorId: Sponsor entity ID, if any.
    ///   - sponsorAmount: Sponsor prize amount, if any.
    init(
        id: UUID = UUID(),
        title: String,
        challengeDescription: String,
        personalityRequired: UUID? = nil,
        targetWordCount: Int? = nil,
        targetSessionCount: Int? = nil,
        startDate: Date,
        endDate: Date,
        participantCount: Int = 0,
        sponsorId: UUID? = nil,
        sponsorAmount: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.challengeDescription = challengeDescription
        self.personalityRequired = personalityRequired
        self.targetWordCount = targetWordCount
        self.targetSessionCount = targetSessionCount
        self.startDate = startDate
        self.endDate = endDate
        self.participantCount = participantCount
        self.sponsorId = sponsorId
        self.sponsorAmount = sponsorAmount
    }
}
