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
    private let trialStoreKey = "ghostwriter_marketplace_trialed_ids"

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
        guard canTryPersonality(personality) else { return }
        hapticService.personalityHaptic(pattern: personality.hapticPattern)
        try? await Task.sleep(for: .milliseconds(280))
        hapticService.lightTap()
        markTrialUsed(for: personality)
    }

    func isOwned(_ personality: GhostPersonality) -> Bool {
        personalityService.availablePersonalities.contains { $0.id == personality.id }
    }

    func canTryPersonality(_ personality: GhostPersonality) -> Bool {
        if isOwned(personality) { return true }
        return !trialedPersonalityIds().contains(personality.id.uuidString)
    }

    func trialButtonTitle(for personality: GhostPersonality) -> String {
        canTryPersonality(personality) ? "Try 1 Session" : "Trial Used"
    }

    func creatorPayoutText(for personality: GhostPersonality) -> String? {
        guard let price = personality.purchasePrice else { return nil }
        return String(format: "Creator earns $%.2f (70%%)", price * 0.70)
    }

    private func markTrialUsed(for personality: GhostPersonality) {
        var ids = trialedPersonalityIds()
        ids.insert(personality.id.uuidString)
        UserDefaults.standard.set(Array(ids), forKey: trialStoreKey)
    }

    private func trialedPersonalityIds() -> Set<String> {
        let raw = UserDefaults.standard.stringArray(forKey: trialStoreKey) ?? []
        return Set(raw)
    }
}
