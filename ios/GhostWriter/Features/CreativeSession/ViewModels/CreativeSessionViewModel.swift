import Foundation
import SwiftUI

// MARK: - CreativeSessionViewModel

/// Central ViewModel for the GhostBoard creative canvas.
///
/// Manages the active writing session, live text input with debounced AI
/// suggestion generation, flow-state detection based on typing cadence,
/// and bidirectional feedback on AI suggestions.
@Observable
final class CreativeSessionViewModel {

    // MARK: - Published State

    var sessionText: String = "" {
        didSet { debounceTextInput() }
    }

    var suggestions: [GhostSuggestion] = []
    var currentSession: CreativeSession?
    var isLoading: Bool = false
    var error: Error?
    var flowScore: Double = 0
    var selectedSessionType: SessionType = .writing
    var currentPersonalityId: UUID?
    var sessionStartTime: Date?
    var isPaused: Bool = false

    // MARK: - Computed

    var wordCount: Int {
        sessionText.split(whereSeparator: \.isWhitespace).count
    }

    var isInFlowState: Bool {
        flowScore > AppConstants.flowStateThreshold
    }

    var sessionDuration: TimeInterval {
        guard let start = sessionStartTime else { return 0 }
        return Date.now.timeIntervalSince(start)
    }

    var formattedDuration: String {
        let total = Int(sessionDuration)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var hasActiveSession: Bool {
        currentSession != nil && sessionStartTime != nil
    }

    // MARK: - Private

    private var debounceTask: Task<Void, Never>?
    private var typingEvents: [(timestamp: Date, wordCount: Int)] = []

    // MARK: - Session Lifecycle

    func startSession(type: SessionType, personalityId: UUID) async {
        selectedSessionType = type
        currentPersonalityId = personalityId
        sessionStartTime = .now
        sessionText = ""
        suggestions = []
        flowScore = 0
        typingEvents = []
        error = nil
        isPaused = false

        currentSession = CreativeSession(
            userId: UUID(),
            type: type,
            personalityId: personalityId
        )
    }

    func endSession() async {
        debounceTask?.cancel()

        currentSession?.endTime = .now
        currentSession?.isLive = false
        currentSession?.wordCount = wordCount
        currentSession?.flowScore = flowScore

        sessionStartTime = nil
    }

    func togglePause() {
        isPaused.toggle()
    }

    // MARK: - Text Input

    func updateText(_ text: String) {
        sessionText = text
        recordTypingEvent()
    }

    // MARK: - Suggestions

    func generateSuggestions() async {
        let trimmed = sessionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            try await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            suggestions = buildPlaceholderSuggestions()
        } catch {
            self.error = error
        }
    }

    func acceptSuggestion(_ suggestion: GhostSuggestion) async {
        suggestion.accepted = true
        sessionText += " " + suggestion.content
        withAnimation(.easeOut(duration: 0.25)) {
            suggestions.removeAll { $0.id == suggestion.id }
        }
    }

    func rejectSuggestion(_ suggestion: GhostSuggestion) async {
        suggestion.accepted = false
        withAnimation(.easeOut(duration: 0.25)) {
            suggestions.removeAll { $0.id == suggestion.id }
        }
    }

    func rateSuggestion(_ suggestion: GhostSuggestion, rating: Int) async {
        suggestion.userRating = max(-1, min(1, rating))
    }

    // MARK: - Private Helpers

    private func debounceTextInput() {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(AppConstants.debounceInterval * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await generateSuggestions()
        }
    }

    private func recordTypingEvent() {
        let event = (timestamp: Date.now, wordCount: wordCount)
        typingEvents.append(event)
        typingEvents.removeAll { Date.now.timeIntervalSince($0.timestamp) > 300 }
        updateFlowScore()
    }

    private func updateFlowScore() {
        guard typingEvents.count > 2 else { return }

        let intervals: [TimeInterval] = zip(typingEvents.dropFirst(), typingEvents).map {
            $0.0.timestamp.timeIntervalSince($0.1.timestamp)
        }
        guard !intervals.isEmpty else { return }

        let avg = intervals.reduce(0, +) / Double(intervals.count)
        let variance = intervals.map { pow($0 - avg, 2) }.reduce(0, +) / Double(intervals.count)

        flowScore = max(0, min(100, 100 - (variance * 10)))
    }

    private func buildPlaceholderSuggestions() -> [GhostSuggestion] {
        let sessionId = currentSession?.id ?? UUID()
        let personalityId = currentPersonalityId ?? UUID()
        let tail = String(sessionText.suffix(120))

        return [
            GhostSuggestion(
                sessionId: sessionId,
                personalityId: personalityId,
                content: "Consider expanding on this thought with a concrete example that grounds the idea...",
                type: .continuation,
                confidenceScore: 0.87,
                contextBefore: tail
            ),
            GhostSuggestion(
                sessionId: sessionId,
                personalityId: personalityId,
                content: "What if you approached this from the opposite perspective entirely?",
                type: .challenge,
                confidenceScore: 0.72,
                contextBefore: tail
            ),
        ]
    }
}
