import Foundation
import Observation

@Observable
final class SubscriptionViewModel {

    var currentTier: SubscriptionTier = .free
    var availableSubscriptions: [Subscription] = []
    var isLoading: Bool = false
    var isPurchasing: Bool = false
    var selectedTier: SubscriptionTier?
    var selectedPeriod: SubscriptionPeriod = .monthly
    var error: Error?
    var showSuccessAlert: Bool = false

    private let service: SubscriptionService

    init(service: SubscriptionService = SubscriptionService()) {
        self.service = service
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.loadProducts()
            availableSubscriptions = service.availableSubscriptions
            currentTier = service.currentTier
        } catch {
            self.error = error
        }
    }

    func purchase(tier: SubscriptionTier) async throws {
        guard let subscription = availableSubscriptions.first(where: {
            $0.tier == tier && $0.period == selectedPeriod
        }) else { return }

        isPurchasing = true
        defer { isPurchasing = false }

        try await service.purchase(subscription)
        currentTier = service.currentTier
        showSuccessAlert = true
    }

    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }

        try await service.restorePurchases()
        currentTier = service.currentTier
    }

    var displayTiers: [SubscriptionTier] {
        [.free, .creator, .pro, .studio]
    }

    func price(for tier: SubscriptionTier) -> String {
        if tier == .free { return "Free" }
        guard let sub = availableSubscriptions.first(where: {
            $0.tier == tier && $0.period == selectedPeriod
        }) else { return "—" }
        return "$\(sub.price)"
    }

    func monthlyEquivalent(for tier: SubscriptionTier) -> String? {
        guard selectedPeriod == .yearly,
              let sub = availableSubscriptions.first(where: {
                  $0.tier == tier && $0.period == .yearly
              }) else { return nil }
        let monthly = sub.price / 12
        return "$\(monthly)/mo"
    }

    func tierColor(for tier: SubscriptionTier) -> (primary: String, secondary: String) {
        switch tier {
        case .free:       ("E8E8E8", "E8E8E8")
        case .creator:    ("00FF88", "00D9FF")
        case .pro:        ("00D9FF", "FF00FF")
        case .studio:     ("FFD700", "FF00FF")
        case .enterprise: ("FF00FF", "FFD700")
        }
    }
}
