import Foundation

// MARK: - SubscriptionTier

/// Available subscription tiers with increasing feature access.
enum SubscriptionTier: String, Codable, Hashable, CaseIterable, Identifiable, Sendable {

    /// Free tier with basic features.
    case free

    /// Creator tier with enhanced session tools.
    case creator

    /// Pro tier with advanced AI and analytics.
    case pro

    /// Studio tier with collaboration and monetization features.
    case studio

    /// Enterprise tier with full platform access and priority support.
    case enterprise

    /// Stable identity derived from the raw value.
    var id: String { rawValue }

    /// A human-readable name for display in the UI.
    var displayName: String {
        switch self {
        case .free:       "Free"
        case .creator:    "Creator"
        case .pro:        "Pro"
        case .studio:     "Studio"
        case .enterprise: "Enterprise"
        }
    }

    /// Monthly price in USD for this tier.
    var monthlyPrice: Decimal {
        switch self {
        case .free:       0
        case .creator:    9.99
        case .pro:        19.99
        case .studio:     39.99
        case .enterprise: 99.99
        }
    }

    /// Feature descriptions included in this tier.
    var features: [String] {
        switch self {
        case .free:
            [
                "3 sessions per day",
                "1 built-in personality",
                "Basic clip sharing"
            ]
        case .creator:
            [
                "Unlimited sessions",
                "All built-in personalities",
                "HD clip export",
                "Basic analytics"
            ]
        case .pro:
            [
                "Everything in Creator",
                "Custom personality creation",
                "Advanced AI suggestions",
                "Detailed analytics",
                "Priority support"
            ]
        case .studio:
            [
                "Everything in Pro",
                "Live Jam collaboration",
                "Monetization tools",
                "Personality marketplace access",
                "Team management"
            ]
        case .enterprise:
            [
                "Everything in Studio",
                "Custom AI model training",
                "Dedicated account manager",
                "SLA guarantee",
                "API access",
                "White-label options"
            ]
        }
    }
}

// MARK: - SubscriptionPeriod

/// Billing period for a subscription.
enum SubscriptionPeriod: String, Codable, Hashable, CaseIterable, Identifiable, Sendable {

    /// Billed every month.
    case monthly

    /// Billed once per year.
    case yearly

    /// Stable identity derived from the raw value.
    var id: String { rawValue }

    /// A human-readable label for display in the UI.
    var displayName: String {
        switch self {
        case .monthly: "Monthly"
        case .yearly:  "Yearly"
        }
    }
}

// MARK: - Subscription

/// An in-app subscription product available for purchase.
struct Subscription: Identifiable, Codable, Hashable, Sendable {

    /// The App Store product identifier.
    var id: String

    /// The subscription tier.
    var tier: SubscriptionTier

    /// The displayed price.
    var price: Decimal

    /// The billing period.
    var period: SubscriptionPeriod

    /// Creates a new subscription descriptor.
    ///
    /// - Parameters:
    ///   - id: App Store product identifier.
    ///   - tier: Subscription tier.
    ///   - price: Display price.
    ///   - period: Billing period.
    init(
        id: String,
        tier: SubscriptionTier,
        price: Decimal,
        period: SubscriptionPeriod
    ) {
        self.id = id
        self.tier = tier
        self.price = price
        self.period = period
    }
}
