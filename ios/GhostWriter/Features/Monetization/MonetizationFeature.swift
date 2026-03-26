import Foundation
import SwiftUI

public struct MonetizationFeature {
    public static let views = MonetizationViews.self
    public static let services = MonetizationServices.self
}

public enum MonetizationViews {
    public static func subscriptionView() -> some View {
        SubscriptionView()
    }

    public static func monetizationEarningsView() -> some View {
        MonetizationEarningsView()
    }
}

public enum MonetizationServices {
    public static func makeSubscriptionService() -> SubscriptionService {
        SubscriptionService()
    }

    public static func makePaymentService() -> PaymentService {
        PaymentService()
    }
}

public typealias Sub = Subscription
public typealias Tier = SubscriptionTier
public typealias Period = SubscriptionPeriod
