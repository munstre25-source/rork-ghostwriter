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

    private var jamTask: Task<Void, Never>?

    func startLiveJam(with collaboratorId: UUID) async throws {
        isLoading = true
        defer { isLoading = false }
        isConnected = true
        collaboratorName = "Creator_\(collaboratorId.uuidString.prefix(4))"

        jamTask = Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.simulateRemoteUpdates() }
                group.addTask { await self.generateSharedSuggestions() }
            }
        }
    }

    func sendText(_ text: String) async {
        localText = text
        updateCollaborationScore()
    }

    func endLiveJam() async {
        jamTask?.cancel()
        jamTask = nil
        isConnected = false
    }

    func voteSuggestion(_ suggestion: GhostSuggestion, accept: Bool) async {
        if let idx = sharedSuggestions.firstIndex(where: { $0.id == suggestion.id }) {
            sharedSuggestions[idx].accepted = accept
        }
    }

    private func simulateRemoteUpdates() async {
        let phrases = [
            "Interesting approach...",
            "What if we tried a different angle?",
            "Building on that idea, I think we could...",
            "I see another perspective here...",
            "This reminds me of a concept we could expand on..."
        ]
        for phrase in phrases {
            guard !Task.isCancelled else { return }
            try? await Task.sleep(for: .seconds(Double.random(in: 2...5)))
            remoteText += (remoteText.isEmpty ? "" : " ") + phrase
            updateCollaborationScore()
        }
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
            try? await Task.sleep(for: .seconds(Double.random(in: 3...6)))
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
