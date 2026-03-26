import UIKit
import Observation

/// In-memory image cache with async loading and preloading support.
///
/// Uses `NSCache` for automatic memory management and `URLSession`
/// for fetching remote images.
@Observable
final class ImageCacheService: @unchecked Sendable {

    private var cache = NSCache<NSString, UIImage>()
    private let session: URLSession

    /// Creates a new image cache service.
    ///
    /// - Parameters:
    ///   - countLimit: Maximum number of images to cache. Defaults to 100.
    ///   - totalCostLimit: Maximum total cost in bytes. Defaults to 50 MB.
    init(countLimit: Int = 100, totalCostLimit: Int = 50 * 1024 * 1024) {
        self.session = URLSession(configuration: .default)
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit
    }

    /// Returns a cached image for the URL, fetching it from the network if needed.
    ///
    /// - Parameter url: The remote image URL.
    /// - Returns: The loaded image, or `nil` if fetching fails.
    func cachedImage(for url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString

        if let cached = cache.object(forKey: key) {
            return cached
        }

        do {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            cache.setObject(image, forKey: key, cost: data.count)
            return image
        } catch {
            print("[ImageCache] Failed to load image from \(url): \(error)")
            return nil
        }
    }

    /// Removes all cached images from memory.
    func clearCache() {
        cache.removeAllObjects()
    }

    /// Preloads images from a batch of URLs into the cache.
    ///
    /// Fetches all URLs concurrently using a task group.
    ///
    /// - Parameter urls: The image URLs to preload.
    func preloadImages(urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask { [weak self] in
                    _ = await self?.cachedImage(for: url)
                }
            }
        }
    }
}
