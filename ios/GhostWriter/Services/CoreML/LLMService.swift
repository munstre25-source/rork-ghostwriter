import Foundation
import Observation

// MARK: - ModelState

/// Represents the lifecycle state of the on-device language model.
enum ModelState: String, Sendable {
    case unloaded
    case loading
    case ready
    case error
}

// MARK: - LLMError

/// Errors that can occur during on-device LLM operations.
enum LLMError: Error, LocalizedError, Sendable {
    case modelNotReady
    case loadingFailed
    case generationFailed
    case tokenizationFailed
    case invalidParameters

    var errorDescription: String? {
        switch self {
        case .modelNotReady:        "The language model is not ready for inference."
        case .loadingFailed:        "Failed to load the quantized model."
        case .generationFailed:     "Text generation failed."
        case .tokenizationFailed:   "Tokenization failed."
        case .invalidParameters:    "Invalid generation parameters."
        }
    }
}

// MARK: - LLMService

/// On-device large language model management service.
///
/// Provides mock implementations with an architecture ready for
/// Llama 2 / GPT-2 quantized model integration.
@Observable
final class LLMService: @unchecked Sendable {

    /// Current lifecycle state of the loaded model.
    var modelState: ModelState = .unloaded

    private let mockVocabulary: [String] = [
        "the", "a", "is", "in", "to", "and", "of", "that", "it", "for",
        "was", "on", "are", "with", "as", "this", "but", "be", "have", "from",
        "or", "an", "they", "which", "one", "you", "all", "were", "her", "would",
        "there", "their", "will", "when", "who", "make", "can", "like", "time",
        "just", "him", "know", "take", "people", "into", "year", "your", "good",
        "some", "could", "them", "see", "other", "than", "then", "now", "look",
        "only", "come", "its", "over", "think", "also", "back", "after", "use",
        "two", "how", "our", "work", "first", "well", "way", "even", "new",
        "want", "because", "any", "these", "give", "day", "most", "us", "great"
    ]

    /// Loads a quantized language model into memory.
    ///
    /// Transitions ``modelState`` from ``ModelState/unloaded`` through
    /// ``ModelState/loading`` to ``ModelState/ready``.
    ///
    /// - Throws: ``LLMError/loadingFailed`` if the model cannot be loaded.
    func loadQuantizedModel() async throws {
        guard modelState != .ready else { return }

        modelState = .loading

        do {
            try await Task.sleep(for: .seconds(Double.random(in: 1.5...3.0)))
            modelState = .ready
        } catch {
            modelState = .error
            throw LLMError.loadingFailed
        }
    }

    /// Generates text from a prompt using the loaded model.
    ///
    /// - Parameters:
    ///   - prompt: The input prompt to continue.
    ///   - maxTokens: Maximum number of tokens to generate.
    ///   - temperature: Sampling temperature controlling randomness (0.0–2.0).
    /// - Returns: The generated text.
    /// - Throws: ``LLMError/modelNotReady`` if the model has not been loaded.
    func generate(
        prompt: String,
        maxTokens: Int = 128,
        temperature: Double = 0.7
    ) async throws -> String {
        guard modelState == .ready else { throw LLMError.modelNotReady }
        guard maxTokens > 0, temperature >= 0 else { throw LLMError.invalidParameters }

        try await Task.sleep(for: .seconds(Double.random(in: 0.5...2.0)))

        let tokenCount = min(maxTokens, Int.random(in: 20...80))
        var words: [String] = []
        for _ in 0..<tokenCount {
            if let word = mockVocabulary.randomElement() {
                words.append(word)
            }
        }

        let sentences = stride(from: 0, to: words.count, by: Int.random(in: 8...15)).map { start in
            let end = min(start + Int.random(in: 8...15), words.count)
            var sentence = words[start..<end].joined(separator: " ")
            if let first = sentence.first {
                sentence = String(first).uppercased() + sentence.dropFirst()
            }
            return sentence + "."
        }

        return sentences.joined(separator: " ")
    }

    /// Splits text into tokens using a simplified tokenization scheme.
    ///
    /// - Parameter text: The input text to tokenize.
    /// - Returns: An array of token strings.
    func tokenize(_ text: String) -> [String] {
        text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .flatMap { word -> [String] in
                if word.count > 4 {
                    let mid = word.index(word.startIndex, offsetBy: word.count / 2)
                    return [String(word[..<mid]), String(word[mid...])]
                }
                return [word]
            }
    }
}
