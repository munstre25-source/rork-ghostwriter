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
        case .studio:     49.99
        case .enterprise: 0
        }
    }

    /// Feature descriptions included in this tier.
    var features: [String] {
        switch self {
        case .free:
            [
                "1 Live Jam/month",
                "The Muse personality",
                "5-minute sessions",
                "Standard export with watermark",
                "Ad-supported (light)",
                "No clip monetization"
            ]
        case .creator:
            [
                "Unlimited sessions",
                "5 built-in personalities",
                "Unlimited Live Jams",
                "HQ export (no watermark)",
                "Creator dashboard",
                "Clip monetization (70% share)",
                "Weekly creative reports",
                "Basic personality customization"
            ]
        case .pro:
            [
                "Everything in Creator",
                "20 personalities including premium",
                "Visual custom personality builder",
                "Advanced analytics (mood + flow)",
                "Detailed analytics",
                "Priority support",
                "Ad-free experience",
                "Early access features",
                "Exclusive badges"
            ]
        case .studio:
            [
                "Everything in Pro",
                "Team workspace (up to 5)",
                "Team personalities",
                "Team analytics + collab logs",
                "Admin controls + permissions",
                "Team billing",
                "Dedicated support"
            ]
        case .enterprise:
            [
                "Unlimited everything",
                "Dedicated support",
                "Custom integrations",
                "White-label options",
                "API access",
                "Advanced security + SSO"
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
