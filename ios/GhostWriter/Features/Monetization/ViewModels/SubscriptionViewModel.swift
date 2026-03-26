import Foundation
import Observation

/// Presentation logic for the subscription paywall.
///
/// ## Overview
///
/// `SubscriptionViewModel` bridges ``SubscriptionService`` and the SwiftUI
/// subscription view by exposing loading, purchasing, and restore workflows
/// as observable state. Formatted prices originate from StoreKit (or the
/// mock fallback) rather than being hard-coded.
///
/// ## Typical Usage
///
/// Inject the shared ``SubscriptionService`` that lives in the SwiftUI
/// environment:
///
/// ```swift
/// @Environment(SubscriptionService.self) private var service
/// @State private var viewModel: SubscriptionViewModel
///
/// init(service: SubscriptionService) {
///     _viewModel = State(initialValue: SubscriptionViewModel(service: service))
/// }
/// ```
@Observable
final class SubscriptionViewModel {

    // MARK: Observable State

    /// The user's active subscription tier, kept in sync with the service.
    var currentTier: SubscriptionTier = .free

    /// Products available for purchase.
    var availableSubscriptions: [Subscription] = []

    /// `true` while products are loading or purchases are being restored.
    var isLoading = false

    /// `true` while a purchase transaction is in flight.
    var isPurchasing = false

    /// The tier currently being purchased (drives per-card spinners).
    var selectedTier: SubscriptionTier?

    /// The billing period selected by the user.
    var selectedPeriod: SubscriptionPeriod = .monthly

    /// The most recent error, if any.
    var error: Error?

    /// A user-facing description of the most recent error.
    var errorMessage: String?

    /// Drives the post-purchase success alert.
    var showSuccessAlert = false

    // MARK: Private

    private let service: SubscriptionService

    // MARK: Init

    /// Creates a view model backed by the given subscription service.
    ///
    /// - Parameter service: The ``SubscriptionService`` instance, typically
    ///   obtained from the SwiftUI environment.
    init(service: SubscriptionService) {
        self.service = service
    }

    // MARK: - Actions

    /// Loads available products and synchronises the current tier.
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.loadProducts()
            availableSubscriptions = service.availableSubscriptions
            currentTier = service.currentTier
        } catch {
            self.error = error
            self.errorMessage = error.localizedDescription
        }
    }

    /// Purchases the subscription matching the given tier and the currently
    /// selected billing period.
    ///
    /// - Parameter tier: The ``SubscriptionTier`` to purchase.
    func purchase(tier: SubscriptionTier) async {
        guard let subscription = availableSubscriptions.first(where: {
            $0.tier == tier && $0.period == selectedPeriod
        }) else { return }

        isPurchasing = true
        selectedTier = tier
        defer {
            isPurchasing = false
            selectedTier = nil
        }

        do {
            try await service.purchase(subscription)
            currentTier = service.currentTier
            showSuccessAlert = true
        } catch SubscriptionError.cancelled {
            // User dismissed the payment sheet — nothing to surface.
        } catch {
            self.error = error
            self.errorMessage = error.localizedDescription
        }
    }

    /// Restores previously purchased subscriptions via `AppStore.sync()`.
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.restorePurchases()
            currentTier = service.currentTier
        } catch {
            self.error = error
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Derived Display Data

    /// The ordered tiers shown on the paywall.
    var displayTiers: [SubscriptionTier] {
        [.free, .creator, .pro, .studio, .enterprise]
    }

    /// Returns a locale-formatted price string for the given tier and the
    /// currently selected period, sourced from StoreKit when available.
    func price(for tier: SubscriptionTier) -> String {
        if tier == .free { return "Free" }
        guard let sub = availableSubscriptions.first(where: {
            $0.tier == tier && $0.period == selectedPeriod
        }) else { return "—" }
        return service.formattedPrices[sub.id] ?? "$\(sub.price)"
    }

    /// For yearly plans returns the per-month equivalent formatted for display.
    func monthlyEquivalent(for tier: SubscriptionTier) -> String? {
        guard selectedPeriod == .yearly,
              let sub = availableSubscriptions.first(where: {
                  $0.tier == tier && $0.period == .yearly
              }) else { return nil }
        let monthly = sub.price / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        let formatted = formatter.string(from: monthly as NSDecimalNumber) ?? "$\(monthly)"
        return "\(formatted)/mo"
    }

    /// Gradient colour pair for the given tier.
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
