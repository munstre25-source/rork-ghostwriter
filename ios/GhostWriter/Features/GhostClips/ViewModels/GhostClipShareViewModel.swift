import SwiftUI
import Foundation
import UIKit

enum SharePlatform: String, CaseIterable, Identifiable {
    case tiktok, instagram, youtube, twitter, generic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tiktok: "TikTok"
        case .instagram: "Instagram"
        case .youtube: "YouTube"
        case .twitter: "X / Twitter"
        case .generic: "More"
        }
    }

    var icon: String {
        switch self {
        case .tiktok: "play.rectangle.fill"
        case .instagram: "camera.fill"
        case .youtube: "play.tv.fill"
        case .twitter: "bubble.left.fill"
        case .generic: "square.and.arrow.up"
        }
    }

    var color: Color {
        switch self {
        case .tiktok: .ghostMagenta
        case .instagram: .ghostGold
        case .youtube: .red
        case .twitter: .ghostCyan
        case .generic: .gray
        }
    }
}

@Observable
final class GhostClipShareViewModel: @unchecked Sendable {
    var clip: GhostClip?
    var shareURL: URL?
    var isSharing: Bool = false
    var selectedPlatform: SharePlatform?
    var caption: String = ""

    func generateShareURL() async throws -> URL {
        guard let clip else {
            throw URLError(.badURL)
        }
        let url = URL(string: "https://ghostwriter.app/clip/\(clip.id.uuidString)")!
        shareURL = url
        return url
    }

    func shareToExternal(platform: SharePlatform) async throws {
        selectedPlatform = platform
        isSharing = true
        defer { isSharing = false }
        let deepLink = try await generateShareURL()
        guard let platformURL = composePlatformShareURL(platform: platform, deepLink: deepLink) else {
            return
        }
        await MainActor.run {
            UIApplication.shared.open(platformURL)
        }
    }

    func copyLink() {
        guard let url = shareURL else { return }
        UIPasteboard.general.string = url.absoluteString
    }

    private func composePlatformShareURL(platform: SharePlatform, deepLink: URL) -> URL? {
        let encodedLink = deepLink.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? deepLink.absoluteString
        let encodedCaption = caption.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? caption

        switch platform {
        case .twitter:
            return URL(string: "https://twitter.com/intent/tweet?text=\(encodedCaption)%20\(encodedLink)")
        case .youtube:
            return URL(string: "https://www.youtube.com/upload")
        case .instagram:
            return URL(string: "https://www.instagram.com/")
        case .tiktok:
            return URL(string: "https://www.tiktok.com/upload")
        case .generic:
            return deepLink
        }
    }
}
