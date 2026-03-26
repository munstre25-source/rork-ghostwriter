import Foundation
import Observation

// MARK: - CoreMLError

/// Errors that can occur during on-device AI operations.
enum CoreMLError: Error, LocalizedError, Sendable {
    case modelNotLoaded
    case generationFailed
    case invalidInput
    case confidenceScoringFailed

    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:           "The AI model has not been loaded yet."
        case .generationFailed:         "Text generation failed."
        case .invalidInput:             "The provided input is invalid."
        case .confidenceScoringFailed:  "Confidence scoring failed."
        }
    }
}

// MARK: - CoreMLService

/// Main service for on-device AI text generation and suggestion scoring.
///
/// Provides mock implementations that simulate realistic AI behavior with
/// random delays. The architecture is ready for real CoreML model integration.
@Observable
final class CoreMLService: @unchecked Sendable {

    /// Whether the underlying AI model has been loaded into memory.
    var isModelLoaded: Bool = false

    private let mockSuggestions: [String] = [
        "Consider exploring this theme from a different angle — what if the protagonist already knew the truth?",
        "This paragraph could benefit from a stronger opening hook. Try starting with an action or a question.",
        "The rhythm here feels rushed. Adding a breath between these two ideas would strengthen the impact.",
        "What if you leaned into the metaphor you introduced earlier? It could tie the whole piece together.",
        "Try flipping the perspective — how would the antagonist describe this same moment?",
        "This section has great energy. Consider expanding on the sensory details to make it even more immersive.",
        "The transition between these ideas is abrupt. A bridging sentence could smooth the flow.",
        "You've set up an interesting tension here. Don't resolve it too quickly — let the reader sit with it."
    ]

    /// Loads the AI model into memory for inference.
    ///
    /// - Throws: ``CoreMLError`` if model loading fails.
    func loadModel() async throws {
        guard !isModelLoaded else { return }
        try await simulateDelay(range: 1.0...2.0)
        isModelLoaded = true
    }

    /// Generates text continuation based on a prompt and personality.
    ///
    /// - Parameters:
    ///   - prompt: The user's current text context.
    ///   - personality: The ghost personality guiding generation style.
    /// - Returns: A generated text continuation.
    /// - Throws: ``CoreMLError/modelNotLoaded`` if the model has not been loaded.
    func generateText(prompt: String, personality: GhostPersonality) async throws -> String {
        guard isModelLoaded else { throw CoreMLError.modelNotLoaded }
        guard !prompt.isEmpty else { throw CoreMLError.invalidInput }

        try await simulateDelay(range: 0.5...1.5)

        let templates: [String] = [
            "Building on your idea, \(personality.name) suggests: ",
            "From \(personality.name)'s perspective: ",
            "Continuing in the \(personality.responseStyle) style: "
        ]

        let prefix = templates.randomElement() ?? ""
        let body = mockSuggestions.randomElement() ?? "Keep writing — you're on the right track."
        return prefix + body
    }

    /// Scores how confident the AI is about a suggestion given its context.
    ///
    /// - Parameters:
    ///   - suggestion: The suggestion text to score.
    ///   - context: The surrounding text context.
    /// - Returns: A confidence score between 0 and 1.
    /// - Throws: ``CoreMLError/modelNotLoaded`` if the model has not been loaded.
    func scoreConfidence(suggestion: String, context: String) async throws -> Double {
        guard isModelLoaded else { throw CoreMLError.modelNotLoaded }

        try await simulateDelay(range: 0.3...0.8)

        let lengthFactor = min(Double(context.count) / 200.0, 1.0)
        let randomVariance = Double.random(in: -0.15...0.15)
        return min(max(0.5 + lengthFactor * 0.3 + randomVariance, 0.0), 1.0)
    }

    /// Generates multiple suggestions for the given text using a personality.
    ///
    /// - Parameters:
    ///   - text: The user's current text.
    ///   - personality: The ghost personality guiding suggestions.
    ///   - count: The number of suggestions to generate.
    /// - Returns: An array of ``GhostSuggestion`` instances.
    /// - Throws: ``CoreMLError/modelNotLoaded`` if the model has not been loaded.
    func generateSuggestions(
        for text: String,
        personality: GhostPersonality,
        count: Int = 3
    ) async throws -> [GhostSuggestion] {
        guard isModelLoaded else { throw CoreMLError.modelNotLoaded }

        try await simulateDelay(range: 0.8...2.0)

        let types: [SuggestionType] = SuggestionType.allCases
        let clampedCount = min(max(count, 1), mockSuggestions.count)

        return (0..<clampedCount).map { index in
            let content = mockSuggestions[index % mockSuggestions.count]
            let confidence = Double.random(in: 0.4...0.95)
            let suggestionType = types[index % types.count]

            return GhostSuggestion(
                sessionId: UUID(),
                personalityId: personality.id,
                content: content,
                type: suggestionType,
                confidenceScore: confidence,
                contextBefore: String(text.suffix(100))
            )
        }
    }

    // MARK: - Private

    private func simulateDelay(range: ClosedRange<Double>) async throws {
        let delay = Double.random(in: range)
        try await Task.sleep(for: .seconds(delay))
    }
}
