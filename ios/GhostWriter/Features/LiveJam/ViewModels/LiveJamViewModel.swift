import SwiftUI
import Foundation

@Observable
final class LiveJamViewModel: @unchecked Sendable {
    var localText: String = ""
    var remoteText: String = ""
    var sharedSuggestions: [GhostSuggestion] = []
    var collaborationScore: Double = 0
    var isConnected: Bool = false
    var isLoading: Bool = false
    var collaboratorName: String?
    var error: Error?

    @ObservationIgnored private let sharePlayService = SharePlayService()
    private var jamTask: Task<Void, Never>?
    private var updatesTask: Task<Void, Never>?

    func startLiveJam(with collaboratorId: UUID) async throws {
        isLoading = true
        defer { isLoading = false }
        collaboratorName = "Creator_\(collaboratorId.uuidString.prefix(4))"
        sharePlayService.collaborators = [collaboratorId]
        try await sharePlayService.initializeGroupActivity()
        isConnected = sharePlayService.isConnected

        jamTask = Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.generateSharedSuggestions() }
            }
        }
        updatesTask = Task { [weak self] in
            guard let self else { return }
            for await update in self.sharePlayService.remoteUpdates {
                guard !Task.isCancelled else { break }
                if update.userId != collaboratorId {
                    continue
                }
                self.remoteText = update.text
                self.updateCollaborationScore()
            }
        }
    }

    func sendText(_ text: String) async {
        localText = text
        try? await sharePlayService.broadcast(text: text)
        updateCollaborationScore()
    }

    func endLiveJam() async {
        jamTask?.cancel()
        jamTask = nil
        updatesTask?.cancel()
        updatesTask = nil
        sharePlayService.disconnect()
        isConnected = false
    }

    func voteSuggestion(_ suggestion: GhostSuggestion, accept: Bool) async {
        if let idx = sharedSuggestions.firstIndex(where: { $0.id == suggestion.id }) {
            sharedSuggestions[idx].accepted = accept
        }
    }

    func captureClip() -> GhostClip {
        let merged = [localText, remoteText]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "\n\n")
        let title = merged.split(separator: "\n").first.map(String.init) ?? "Live Jam Moment"
        let clip = GhostClip(
            sessionId: UUID(),
            creatorId: UUID(),
            videoURL: URL(string: "https://ghostwriter.app/livejam/\(UUID().uuidString).mp4")!,
            duration: 30,
            title: String(title.trimmingCharacters(in: .whitespacesAndNewlines).prefix(60)),
            clipDescription: "Captured from a Live Jam collaboration.",
            personalityUsed: "The Muse"
        )
        return clip
    }

    private func generateSharedSuggestions() async {
        let contents = [
            "Consider merging both perspectives into a unified concept...",
            "What if you explored the tension between these two ideas?",
            "There's an interesting pattern forming across both inputs.",
            "Try reframing this from the audience's perspective.",
            "The overlap between your ideas suggests a stronger theme."
        ]
        for content in contents {
            guard !Task.isCancelled else { return }
            try? await Task.sleep(for: .seconds(4))
            let suggestion = GhostSuggestion(
                sessionId: UUID(),
                personalityId: UUID(),
                content: content,
                type: .reframe,
                confidenceScore: Double.random(in: 0.5...0.95),
                contextBefore: localText,
                contextAfter: remoteText
            )
            if sharedSuggestions.count < 5 {
                sharedSuggestions.append(suggestion)
            }
        }
    }

    private func updateCollaborationScore() {
        let localWords = max(1, Double(localText.split(separator: " ").count))
        let remoteWords = max(1, Double(remoteText.split(separator: " ").count))
        collaborationScore = min(localWords, remoteWords) / max(localWords, remoteWords) * 100
    }
}
