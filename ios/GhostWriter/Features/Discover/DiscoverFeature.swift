import Foundation
import SwiftUI

public struct DiscoverFeature {
    public static let views = DiscoverViews.self
    public static let services = DiscoverServices.self
}

public enum DiscoverViews {
    public static func discoverView() -> some View {
        DiscoverView()
    }
}

public enum DiscoverServices {
    public static func makeDiscoveryService() -> DiscoveryService {
        DiscoveryService()
    }
}

public typealias FeedItem = DiscoveryItem
public typealias FeedItemType = DiscoveryItemType
