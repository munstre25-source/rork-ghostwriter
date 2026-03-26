import SwiftUI
import Foundation

@Observable
final class GhostClipEditorViewModel: @unchecked Sendable {
    var clip: GhostClip?
    var title: String = ""
    var clipDescription: String = ""
    var trimStart: Double = 0
    var trimEnd: Double = 30
    var selectedOverlayText: String?
    var selectedMusic: String?
    var isExporting: Bool = false
    var isLoading: Bool = false
    var error: Error?

    func loadClip(id: UUID) async {
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(for: .seconds(0.5))
        clip = GhostClip(
            sessionId: UUID(),
            creatorId: UUID(),
            videoURL: URL(string: "https://ghostwriter.app/clips/\(id)")!,
            duration: 30
        )
        title = clip?.title ?? ""
        clipDescription = clip?.clipDescription ?? ""
        trimEnd = clip?.duration ?? 30
    }

    func updateTrim(start: Double, end: Double) {
        trimStart = max(0, start)
        trimEnd = min(clip?.duration ?? 30, end)
    }

    func addTextOverlay(_ text: String) {
        selectedOverlayText = text
    }

    func exportClip() async throws -> URL {
        isExporting = true
        defer { isExporting = false }
        try await Task.sleep(for: .seconds(1.5))
        return URL(string: "https://ghostwriter.app/exports/\(UUID())")!
    }

    func saveChanges() async throws {
        guard let clip else { return }
        isLoading = true
        defer { isLoading = false }
        clip.title = title
        clip.clipDescription = clipDescription
        try await Task.sleep(for: .seconds(0.5))
    }
}
