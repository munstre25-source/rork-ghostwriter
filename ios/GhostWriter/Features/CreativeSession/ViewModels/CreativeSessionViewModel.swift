import Foundation
import SwiftUI
import SwiftData

@Observable
final class CreativeSessionViewModel: @unchecked Sendable {

    // MARK: - Published State

    var sessionText: String = "" {
        didSet {
            guard sessionText != oldValue, !isBatchUpdating else { return }
            onTextChanged()
        }
    }

    var suggestions: [GhostSuggestion] = []
    var currentSession: CreativeSession?
    var isLoading: Bool = false
    var error: Error?
    var flowScore: Double = 0
    var selectedSessionType: SessionType = .writing
    var selectedPersonality: GhostPersonality?
    var sessionStartTime: Date?
    var isPaused: Bool = false
    var isModelReady: Bool = false

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

    // MARK: - Dependencies

    @ObservationIgnored private let coreMLService: CoreMLService
    @ObservationIgnored private let hapticService: HapticService
    @ObservationIgnored private let analyticsService: AnalyticsService
    @ObservationIgnored private let modelContext: ModelContext

    // MARK: - Private

    @ObservationIgnored private var debounceTask: Task<Void, Never>?
    @ObservationIgnored private var typingEvents: [(timestamp: Date, wordCount: Int)] = []
    @ObservationIgnored private var wasInFlowState: Bool = false
    @ObservationIgnored private var lastLoggedTextLength: Int = 0
    @ObservationIgnored private var isBatchUpdating: Bool = false

    // MARK: - Init

    init(
        coreMLService: CoreMLService,
        hapticService: HapticService,
        analyticsService: AnalyticsService,
        modelContext: ModelContext
    ) {
        self.coreMLService = coreMLService
        self.hapticService = hapticService
        self.analyticsService = analyticsService
        self.modelContext = modelContext
    }

    // MARK: - Model Loading

    func loadModel() async {
        do {
            try await coreMLService.loadModel()
            isModelReady = coreMLService.isModelLoaded
        } catch {
            self.error = error
        }
    }

    // MARK: - Personality Seeding

    func ensureBuiltInPersonalities() {
        do {
            let descriptor = FetchDescriptor<GhostPersonality>()
            let existing = try modelContext.fetchCount(descriptor)
            guard existing == 0 else { return }

            let builtIns: [GhostPersonality] = [
                .theMuse(), .theArchitect(), .theCritic(), .theVisionary(), .theAnalyst()
            ]
            for personality in builtIns {
                modelContext.insert(personality)
            }
            try modelContext.save()
        } catch {
            self.error = error
        }
    }

    // MARK: - Session Lifecycle

    func startSession(type: SessionType, personality: GhostPersonality) {
        selectedSessionType = type
        selectedPersonality = personality
        sessionStartTime = .now
        flowScore = 0
        suggestions = []
        typingEvents = []
        error = nil
        isPaused = false
        wasInFlowState = false
        lastLoggedTextLength = 0

        isBatchUpdating = true
        sessionText = ""
        isBatchUpdating = false

        let session = CreativeSession(
            userId: UUID(),
            type: type,
            personalityId: personality.id
        )
        modelContext.insert(session)
        currentSession = session
        saveContext()

        analyticsService.trackSessionStart(type: type)
    }

    func endSession() {
        debounceTask?.cancel()

        guard let session = currentSession else { return }
        session.endTime = .now
        session.isLive = false
        session.wordCount = wordCount
        session.flowScore = flowScore
        saveContext()

        analyticsService.trackSessionEnd(
            wordCount: wordCount,
            flowScore: flowScore,
            duration: sessionDuration
        )

        sessionStartTime = nil
        currentSession = nil
        suggestions = []
    }

    func togglePause() {
        isPaused.toggle()
    }

    // MARK: - Suggestions

    func generateSuggestions() async {
        let trimmed = sessionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isPaused else { return }
        guard let personality = selectedPersonality else { return }
        guard let session = currentSession else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let newSuggestions = try await coreMLService.generateSuggestions(
                for: trimmed,
                personality: personality,
                count: 3
            )
            guard !Task.isCancelled else { return }

            for suggestion in newSuggestions {
                suggestion.sessionId = session.id
                modelContext.insert(suggestion)
            }
            saveContext()

            withAnimation(.spring(duration: 0.4)) {
                suggestions = newSuggestions
            }

            if let best = newSuggestions.max(by: { $0.confidenceScore < $1.confidenceScore }) {
                hapticService.suggestionAppeared(confidence: best.confidenceScore)
            }
        } catch is CancellationError {
            // Debounce cancelled — expected, not an error
        } catch {
            self.error = error
        }
    }

    func acceptSuggestion(_ suggestion: GhostSuggestion) {
        suggestion.accepted = true

        isBatchUpdating = true
        sessionText += " " + suggestion.content
        isBatchUpdating = false

        currentSession?.ideaCount += 1
        currentSession?.wordCount = wordCount

        withAnimation(.easeOut(duration: 0.25)) {
            suggestions.removeAll { $0.id == suggestion.id }
        }

        saveContext()
        hapticService.mediumTap()
        analyticsService.trackSuggestionAccepted(suggestionId: suggestion.id)

        debounceTextInput()
    }

    func rejectSuggestion(_ suggestion: GhostSuggestion) {
        suggestion.accepted = false

        withAnimation(.easeOut(duration: 0.25)) {
            suggestions.removeAll { $0.id == suggestion.id }
        }

        saveContext()
        hapticService.lightTap()
        analyticsService.trackSuggestionRejected(suggestionId: suggestion.id)
    }

    func rateSuggestion(_ suggestion: GhostSuggestion, rating: Int) {
        suggestion.userRating = max(-1, min(1, rating))
        saveContext()
    }

    // MARK: - Private — Text Pipeline

    private func onTextChanged() {
        recordTypingEvent()
        appendToRawInputLog()
        debounceTextInput()
    }

    private func debounceTextInput() {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(AppConstants.debounceInterval))
            guard !Task.isCancelled else { return }
            await self?.generateSuggestions()
        }
    }

    // MARK: - Private — Flow State Detection

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

        let newScore = max(0, min(100, 100 - (variance * 10)))
        flowScore = newScore
        currentSession?.flowScore = newScore

        let nowInFlow = newScore > AppConstants.flowStateThreshold
        if nowInFlow && !wasInFlowState {
            hapticService.flowStatePulse()
        }
        wasInFlowState = nowInFlow
    }

    // MARK: - Private — Input Log

    private func appendToRawInputLog() {
        guard let session = currentSession else { return }
        let currentLength = sessionText.count
        guard currentLength > lastLoggedTextLength else { return }

        let startIndex = sessionText.index(sessionText.startIndex, offsetBy: lastLoggedTextLength)
        let delta = String(sessionText[startIndex...])
        guard !delta.isEmpty else { return }

        session.rawInputLog.append(delta)
        lastLoggedTextLength = currentLength
    }

    // MARK: - Private — Persistence

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            self.error = error
        }
    }
}
