import Foundation
import Observation

/// Manages the lifecycle of creative sessions including creation,
/// text updates, and AI suggestion generation.
@Observable
final class SessionService: @unchecked Sendable {

    /// All sessions that have not yet ended.
    var activeSessions: [CreativeSession] = []

    /// The session the user is currently working in, if any.
    var currentSession: CreativeSession?

    /// Shared singleton instance.
    static let shared = SessionService()

    private let coreMLService = CoreMLService()

    private init() {}

    /// Starts a new creative session.
    ///
    /// Loads the AI model if needed, creates the session, and sets it as current.
    ///
    /// - Parameters:
    ///   - type: The type of creative activity.
    ///   - personalityId: The ghost personality to use for suggestions.
    /// - Returns: The newly created session.
    /// - Throws: ``CoreMLError`` if the AI model fails to load.
    func startSession(
        type: SessionType,
        personalityId: UUID
    ) async throws -> CreativeSession {
        if !coreMLService.isModelLoaded {
            try await coreMLService.loadModel()
        }

        let session = CreativeSession(
            userId: UUID(),
            type: type,
            personalityId: personalityId
        )

        activeSessions.append(session)
        currentSession = session
        print("[Session] Started \(type.displayName) session: \(session.id)")
        return session
    }

    /// Ends a session and removes it from the active list.
    ///
    /// - Parameter session: The session to end.
    /// - Throws: ``SessionError/storageError`` if the session cannot be persisted.
    func endSession(_ session: CreativeSession) async throws {
        session.endTime = .now
        session.isLive = false

        activeSessions.removeAll { $0.id == session.id }

        if currentSession?.id == session.id {
            currentSession = nil
        }

        print("[Session] Ended session: \(session.id) (words: \(session.wordCount))")
    }

    /// Updates the text content for a session and recalculates metrics.
    ///
    /// - Parameters:
    ///   - text: The updated text content.
    ///   - session: The session to update.
    func updateText(_ text: String, in session: CreativeSession) async {
        session.rawInputLog.append(text)
        session.wordCount = text.split(separator: " ").count

        let flowBoost = min(Double(session.wordCount) / 500.0 * 100.0, 100.0)
        session.flowScore = min(session.flowScore + Double.random(in: 0...5), flowBoost)
    }

    /// Generates AI suggestions for the current state of a session.
    ///
    /// - Parameter session: The session to generate suggestions for.
    /// - Returns: An array of ``GhostSuggestion`` instances.
    /// - Throws: ``CoreMLError`` if generation fails.
    func generateSuggestions(for session: CreativeSession) async throws -> [GhostSuggestion] {
        let currentText = session.rawInputLog.last ?? ""
        let personality = GhostPersonality.theMuse()

        return try await coreMLService.generateSuggestions(
            for: currentText,
            personality: personality,
            count: 3
        )
    }
}
