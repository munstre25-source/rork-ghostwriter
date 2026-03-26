import Foundation
import Observation
import SwiftUI

// MARK: - MarketplaceSortOrder

enum MarketplaceSortOrder: String, CaseIterable, Identifiable, Sendable {
    case trending
    case topRated
    case newest
    case priceHigh
    case priceLow

    var id: String { rawValue }

    var title: String {
        switch self {
        case .trending: "Trending"
        case .topRated: "Top rated"
        case .newest: "Newest"
        case .priceHigh: "Price: high"
        case .priceLow: "Price: low"
        }
    }
}

// MARK: - PersonalityMarketplaceViewModel

@MainActor
@Observable
final class PersonalityMarketplaceViewModel {

    var personalities: [GhostPersonality] = []
    var searchQuery = ""
    var selectedCategory: String?
    var sortOrder: MarketplaceSortOrder = .trending
    var isLoading = false

    private let personalityService: PersonalityService
    private let hapticService: HapticService

    init(personalityService: PersonalityService, hapticService: HapticService) {
        self.personalityService = personalityService
        self.hapticService = hapticService
    }

    var filteredPersonalities: [GhostPersonality] {
        var list = personalities

        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            let q = trimmed.lowercased()
            list = list.filter { personality in
                personality.name.lowercased().contains(q)
                    || personality.personalityDescription.lowercased().contains(q)
                    || personality.traits.contains { $0.lowercased().contains(q) }
            }
        }

        if let category = selectedCategory {
            list = list.filter { personality in
                personality.traits.contains { trait in
                    PersonalityTrait(rawValue: trait)?.displayName == category
                        || trait.lowercased() == category.lowercased()
                }
            }
        }

        switch sortOrder {
        case .trending:
            list.sort { lhs, rhs in
                if lhs.downloads != rhs.downloads { return lhs.downloads > rhs.downloads }
                return lhs.rating > rhs.rating
            }
        case .topRated:
            list.sort { lhs, rhs in
                if lhs.rating != rhs.rating { return lhs.rating > rhs.rating }
                return lhs.downloads > rhs.downloads
            }
        case .newest:
            list.sort { lhs, rhs in lhs.id.uuidString > rhs.id.uuidString }
        case .priceHigh:
            list.sort { lhs, rhs in
                (lhs.purchasePrice ?? 0) > (rhs.purchasePrice ?? 0)
            }
        case .priceLow:
            list.sort { lhs, rhs in
                (lhs.purchasePrice ?? 0) < (rhs.purchasePrice ?? 0)
            }
        }

        return list
    }

    func loadMarketplace() async {
        isLoading = true
        defer { isLoading = false }

        await personalityService.loadBuiltInPersonalities()

        var merged: [GhostPersonality] = []
        var seen = Set<UUID>()

        for p in personalityService.availablePersonalities + personalityService.marketplacePersonalities {
            if seen.insert(p.id).inserted {
                merged.append(p)
            }
        }

        personalities = merged
    }

    func search(query: String) async {
        try? await Task.sleep(for: .milliseconds(120))
        searchQuery = query
    }

    func purchasePersonality(_ personality: GhostPersonality) async throws {
        try await personalityService.purchasePersonality(personality)
        hapticService.successNotification()
    }

    func tryPersonality(_ personality: GhostPersonality) async {
        hapticService.personalityHaptic(pattern: personality.hapticPattern)
        try? await Task.sleep(for: .milliseconds(280))
        hapticService.lightTap()
    }

    func isOwned(_ personality: GhostPersonality) -> Bool {
        personalityService.availablePersonalities.contains { $0.id == personality.id }
    }
}
