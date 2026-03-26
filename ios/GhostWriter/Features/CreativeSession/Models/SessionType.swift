import Foundation

/// The type of creative activity performed during a session.
enum SessionType: String, Codable, Hashable, CaseIterable, Identifiable, Sendable {

    /// Long-form or short-form writing.
    case writing

    /// Idea generation and brainstorming.
    case brainstorming

    /// Code-oriented creative work.
    case coding

    /// Visual or UX design thinking.
    case design

    /// Unstructured, freeform creative exploration.
    case freestyle

    /// Stable identity derived from the raw value.
    var id: String { rawValue }

    /// A human-readable name for display in the UI.
    var displayName: String {
        switch self {
        case .writing:       "Writing"
        case .brainstorming: "Brainstorming"
        case .coding:        "Coding"
        case .design:        "Design"
        case .freestyle:     "Freestyle"
        }
    }

    /// An SF Symbol name representing this session type.
    var icon: String {
        switch self {
        case .writing:       "pencil.line"
        case .brainstorming: "brain.head.profile"
        case .coding:        "chevron.left.forwardslash.chevron.right"
        case .design:        "paintbrush.pointed"
        case .freestyle:     "sparkles"
        }
    }
}

// MARK: - SessionError

/// Errors that can occur during a creative session.
enum SessionError: Error, LocalizedError, Sendable {

    /// The provided input is invalid or malformed.
    case invalidInput

    /// The AI backend failed to process a request.
    case aiProcessingFailed

    /// A network request failed.
    case networkError

    /// Persisting or reading data from storage failed.
    case storageError

    var errorDescription: String? {
        switch self {
        case .invalidInput:       "The input provided is invalid."
        case .aiProcessingFailed: "AI processing failed. Please try again."
        case .networkError:       "A network error occurred. Check your connection."
        case .storageError:       "Failed to save or load data."
        }
    }
}
