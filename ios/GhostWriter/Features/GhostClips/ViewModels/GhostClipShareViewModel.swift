import SwiftUI
import Foundation

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
        isSharing = true
        defer { isSharing = false }
        try await Task.sleep(for: .seconds(0.5))
        let url = URL(string: "https://ghostwriter.app/clip/\(clip?.id.uuidString ?? UUID().uuidString)")!
        shareURL = url
        return url
    }

    func shareToExternal(platform: SharePlatform) async throws {
        selectedPlatform = platform
        isSharing = true
        defer { isSharing = false }
        try await Task.sleep(for: .seconds(1))
    }

    func copyLink() {
        guard let url = shareURL else { return }
        UIPasteboard.general.string = url.absoluteString
    }
}
