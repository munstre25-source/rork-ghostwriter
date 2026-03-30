import Foundation
import Observation

// MARK: - RemoteUpdate

/// A text update received from a remote collaborator during a Live Jam.
struct RemoteUpdate: Sendable {

    /// The collaborator who sent the update.
    var userId: UUID

    /// The updated text content.
    var text: String

    /// When the update was sent.
    var timestamp: Date
}

// MARK: - SharePlayError

/// Errors that can occur during SharePlay operations.
enum SharePlayError: Error, LocalizedError, Sendable {
    case connectionFailed
    case broadcastFailed
    case notConnected
    case sessionExpired

    var errorDescription: String? {
        switch self {
        case .connectionFailed: "Failed to connect to the group activity."
        case .broadcastFailed:  "Failed to broadcast text update."
        case .notConnected:     "Not connected to a SharePlay session."
        case .sessionExpired:   "The SharePlay session has expired."
        }
    }
}

// MARK: - SharePlayService

/// Manages real-time collaborative writing sessions via SharePlay.
///
/// Mock implementation that simulates remote collaborator updates.
/// The architecture supports GroupActivities framework integration.
@Observable
final class SharePlayService: @unchecked Sendable {

    /// Whether the service is connected to an active group activity.
    var isConnected: Bool = false

    /// User IDs of collaborators currently in the session.
    var collaborators: [UUID] = []

    /// An async stream of text updates from remote collaborators.
    var remoteUpdates: AsyncStream<RemoteUpdate> {
        AsyncStream { [weak self] continuation in
            self?.updateContinuation = continuation
        }
    }

    private var updateContinuation: AsyncStream<RemoteUpdate>.Continuation?

    /// Initializes and joins a group activity session.
    ///
    /// - Throws: ``SharePlayError/connectionFailed`` if the session cannot be established.
    func initializeGroupActivity() async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))

        isConnected = true
        collaborators = [UUID(), UUID()]
        print("[SharePlay] Connected with \(collaborators.count) collaborators")

        startSimulatedUpdates()
    }

    /// Broadcasts a text update to all connected collaborators.
    ///
    /// - Parameter text: The text to broadcast.
    /// - Throws: ``SharePlayError/notConnected`` if not in an active session.
    func broadcast(text: String) async throws {
        guard isConnected else { throw SharePlayError.notConnected }

        try await Task.sleep(for: .seconds(Double.random(in: 0.1...0.3)))
        print("[SharePlay] Broadcast text (\(text.count) chars)")
    }

    /// Disconnects from the current group activity session.
    func disconnect() {
        isConnected = false
        collaborators.removeAll()
        updateContinuation?.finish()
        updateContinuation = nil
        print("[SharePlay] Disconnected")
    }

    // MARK: - Private

    private func startSimulatedUpdates() {
        Task { [weak self] in
            guard let self else { return }

            let mockTexts = [
                "Great opening — I'm building on your second paragraph.",
                "What if we take this in a more abstract direction?",
                "Added a metaphor that ties back to the intro.",
                "I love where this is going. Expanding the final section.",
                "Just polished the transitions between sections."
            ]

            while isConnected {
                try? await Task.sleep(for: .seconds(Double.random(in: 3.0...8.0)))
                guard isConnected, let collaborator = collaborators.randomElement() else { break }

                let update = RemoteUpdate(
                    userId: collaborator,
                    text: mockTexts.randomElement() ?? "",
                    timestamp: .now
                )
                updateContinuation?.yield(update)
            }
        }
    }
}
