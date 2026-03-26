import Foundation
import Observation

// MARK: - PersonalityError

/// Errors that can occur during personality operations.
enum PersonalityError: Error, LocalizedError, Sendable {
    case creationFailed
    case publishFailed
    case purchaseFailed
    case ratingFailed
    case notFound
    case alreadyOwned

    var errorDescription: String? {
        switch self {
        case .creationFailed:   "Failed to create personality."
        case .publishFailed:    "Failed to publish personality to the marketplace."
        case .purchaseFailed:   "Failed to purchase personality."
        case .ratingFailed:     "Failed to submit rating."
        case .notFound:         "Personality not found."
        case .alreadyOwned:     "You already own this personality."
        }
    }
}

// MARK: - PersonalityService

/// Manages ghost personality discovery, creation, and marketplace operations.
@Observable
final class PersonalityService: @unchecked Sendable {

    /// Built-in and user-created personalities available locally.
    var availablePersonalities: [GhostPersonality] = []

    /// Personalities listed on the marketplace for purchase.
    var marketplacePersonalities: [GhostPersonality] = []

    /// Loads all built-in personalities into memory.
    func loadBuiltInPersonalities() async {
        try? await Task.sleep(for: .seconds(Double.random(in: 0.3...0.8)))

        availablePersonalities = [
            .theMuse(),
            .theArchitect(),
            .theCritic(),
            .theVisionary(),
            .theAnalyst()
        ]
    }

    /// Creates a new custom ghost personality.
    ///
    /// - Parameters:
    ///   - name: Display name for the personality.
    ///   - traits: Trait keywords describing the personality's style.
    ///   - systemPrompt: The AI system prompt for this personality.
    /// - Returns: The newly created ``GhostPersonality``.
    /// - Throws: ``PersonalityError/creationFailed`` if creation fails.
    func createPersonality(
        name: String,
        traits: [String],
        systemPrompt: String
    ) async throws -> GhostPersonality {
        guard !name.isEmpty, !systemPrompt.isEmpty else {
            throw PersonalityError.creationFailed
        }

        try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.0)))

        let personality = GhostPersonality(
            name: name,
            description: "Custom personality: \(name)",
            systemPrompt: systemPrompt,
            creatorId: UUID(),
            traits: traits
        )

        availablePersonalities.append(personality)
        print("[Personality] Created custom personality: \(name)")
        return personality
    }

    /// Publishes a personality to the marketplace.
    ///
    /// - Parameter personality: The personality to publish.
    /// - Throws: ``PersonalityError/publishFailed`` if publishing fails.
    func publishPersonality(_ personality: GhostPersonality) async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))

        personality.isPublished = true
        marketplacePersonalities.append(personality)
        print("[Personality] Published '\(personality.name)' to marketplace")
    }

    /// Purchases a personality from the marketplace.
    ///
    /// - Parameter personality: The personality to purchase.
    /// - Throws: ``PersonalityError/alreadyOwned`` if the personality is already owned,
    ///   or ``PersonalityError/purchaseFailed`` if the purchase fails.
    func purchasePersonality(_ personality: GhostPersonality) async throws {
        if availablePersonalities.contains(where: { $0.id == personality.id }) {
            throw PersonalityError.alreadyOwned
        }

        try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))

        personality.downloads += 1
        if let price = personality.purchasePrice {
            // Marketplace split: creator receives 70%, platform receives 30%.
            personality.revenue += price * 0.70
        }
        availablePersonalities.append(personality)
        print("[Personality] Purchased '\(personality.name)'")
    }

    /// Submits a rating for a personality.
    ///
    /// - Parameters:
    ///   - personality: The personality to rate.
    ///   - rating: A rating value from 0 to 5.
    /// - Throws: ``PersonalityError/ratingFailed`` if the rating cannot be submitted.
    func ratePersonality(_ personality: GhostPersonality, rating: Double) async throws {
        guard (0...5).contains(rating) else {
            throw PersonalityError.ratingFailed
        }

        try await Task.sleep(for: .seconds(Double.random(in: 0.3...0.8)))

        let totalRatings = Double(personality.usageCount)
        personality.rating = (personality.rating * totalRatings + rating) / (totalRatings + 1)
        personality.usageCount += 1
        print("[Personality] Rated '\(personality.name)' -> \(personality.rating)")
    }
}
