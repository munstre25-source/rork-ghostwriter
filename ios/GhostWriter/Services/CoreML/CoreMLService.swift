import Foundation
import NaturalLanguage
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

// MARK: - TextAnalysis (internal)

/// Aggregated analysis of a text passage produced by NL taggers.
private struct TextAnalysis: Sendable {
    let language: NLLanguage?
    let sentimentScore: Double
    let dominantMood: String
    let keyNouns: [String]
    let keyVerbs: [String]
    let keyAdjectives: [String]
    let sentenceCount: Int
    let wordCount: Int
    let uniqueWordCount: Int
    let averageSentenceLength: Double
    let vocabularyDiversity: Double
}

// MARK: - CoreMLService

/// On-device AI service for text generation, suggestion scoring, and creative analysis.
///
/// Uses Apple's NaturalLanguage framework (`NLTagger`, `NLLanguageRecognizer`) to
/// perform real sentiment analysis, part-of-speech extraction, and vocabulary
/// profiling. All heavy work runs off the main actor via structured concurrency.
///
/// ## Usage
/// ```swift
/// let service = CoreMLService()
/// try await service.loadModel()
/// let suggestions = try await service.generateSuggestions(
///     for: "The rain hammered the old roof…",
///     personality: .theMuse(),
///     count: 3
/// )
/// ```
@Observable
final class CoreMLService: @unchecked Sendable {

    // MARK: Public state

    /// Whether the NL taggers and language resources have been initialized.
    var isModelLoaded: Bool = false

    // MARK: Private NL resources

    private var tagger: NLTagger?
    private var sentimentTagger: NLTagger?
    private var languageRecognizer: NLLanguageRecognizer?

    // MARK: - loadModel

    /// Initializes NL taggers and language-recognition resources.
    ///
    /// Call this once before invoking any generation or scoring APIs.
    /// Subsequent calls are no-ops.
    ///
    /// - Throws: ``CoreMLError`` if initialization fails.
    func loadModel() async throws {
        guard !isModelLoaded else { return }

        // Brief yield to simulate real resource-loading cost (warm-up caches)
        try await Task.sleep(for: .milliseconds(300))

        let posTagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .lemma])
        let sentTagger = NLTagger(tagSchemes: [.sentimentScore])
        let recognizer = NLLanguageRecognizer()

        tagger = posTagger
        sentimentTagger = sentTagger
        languageRecognizer = recognizer
        isModelLoaded = true
    }

    // MARK: - generateText

    /// Generates a context-aware text continuation based on the user's prompt
    /// and the active ghost personality.
    ///
    /// The method analyzes the prompt with NL taggers to extract key themes,
    /// sentiment, and vocabulary, then crafts a continuation that matches
    /// the personality's response style and traits.
    ///
    /// - Parameters:
    ///   - prompt: The user's current text context.
    ///   - personality: The ghost personality guiding generation style.
    /// - Returns: A generated text continuation.
    /// - Throws: ``CoreMLError/modelNotLoaded`` if ``loadModel()`` has not been called,
    ///           or ``CoreMLError/invalidInput`` if the prompt is empty.
    func generateText(prompt: String, personality: GhostPersonality) async throws -> String {
        guard isModelLoaded else { throw CoreMLError.modelNotLoaded }
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CoreMLError.invalidInput
        }

        let analysis = analyzeText(prompt)
        return buildContinuation(from: analysis, text: prompt, personality: personality)
    }

    // MARK: - scoreConfidence

    /// Scores how relevant a suggestion is to its surrounding context using
    /// measurable text properties.
    ///
    /// The score is a weighted composite of:
    /// - **Vocabulary diversity** – ratio of unique words to total words.
    /// - **Sentence structure** – how close average sentence length is to an
    ///   ideal range (12–20 words).
    /// - **Text coherence** – proportion of recognized nouns, verbs, and adjectives
    ///   relative to total word count.
    /// - **Length adequacy** – diminishing-returns curve on word count.
    ///
    /// - Parameters:
    ///   - suggestion: The suggestion text to evaluate.
    ///   - context: The surrounding text that the suggestion relates to.
    /// - Returns: A confidence score in the range `0…1`.
    /// - Throws: ``CoreMLError/modelNotLoaded`` if ``loadModel()`` has not been called.
    func scoreConfidence(suggestion: String, context: String) async throws -> Double {
        guard isModelLoaded else { throw CoreMLError.modelNotLoaded }

        let combined = context + " " + suggestion
        let analysis = analyzeText(combined)

        let diversityScore = analysis.vocabularyDiversity

        let idealAvg = 16.0
        let sentenceDeviation = abs(analysis.averageSentenceLength - idealAvg) / idealAvg
        let structureScore = max(1.0 - sentenceDeviation, 0)

        let contentWordCount = analysis.keyNouns.count + analysis.keyVerbs.count + analysis.keyAdjectives.count
        let coherenceScore = analysis.wordCount > 0
            ? min(Double(contentWordCount) / Double(analysis.wordCount) * 2.0, 1.0)
            : 0

        let lengthScore = min(Double(analysis.wordCount) / 50.0, 1.0)

        let weighted = diversityScore * 0.30
            + structureScore * 0.25
            + coherenceScore * 0.25
            + lengthScore * 0.20

        return min(max(weighted, 0), 1)
    }

    // MARK: - generateSuggestions

    /// Generates multiple context-aware suggestions for the given text using
    /// a ghost personality.
    ///
    /// Suggestions are produced in parallel via a `TaskGroup`. Each suggestion
    /// targets a different ``SuggestionType`` and is tailored to the
    /// personality's traits and response style.
    ///
    /// - Parameters:
    ///   - text: The user's current text.
    ///   - personality: The ghost personality guiding suggestion tone.
    ///   - count: Number of suggestions to generate (clamped to 1…5).
    /// - Returns: An array of ``GhostSuggestion`` instances.
    /// - Throws: ``CoreMLError/modelNotLoaded`` if ``loadModel()`` has not been called.
    func generateSuggestions(
        for text: String,
        personality: GhostPersonality,
        count: Int = 3
    ) async throws -> [GhostSuggestion] {
        guard isModelLoaded else { throw CoreMLError.modelNotLoaded }

        let analysis = analyzeText(text)
        let types = Array(SuggestionType.allCases)
        let clampedCount = min(max(count, 1), types.count)

        return try await withThrowingTaskGroup(of: GhostSuggestion.self) { group in
            for index in 0..<clampedCount {
                let suggestionType = types[index % types.count]
                group.addTask { [self] in
                    let content = buildSuggestion(
                        type: suggestionType,
                        analysis: analysis,
                        text: text,
                        personality: personality
                    )
                    let confidence = try await scoreConfidence(
                        suggestion: content,
                        context: text
                    )
                    return GhostSuggestion(
                        sessionId: UUID(),
                        personalityId: personality.id,
                        content: content,
                        type: suggestionType,
                        confidenceScore: confidence,
                        contextBefore: String(text.suffix(200))
                    )
                }
            }

            var results: [GhostSuggestion] = []
            for try await suggestion in group {
                results.append(suggestion)
            }
            return results
        }
    }

    // MARK: - Private – NL Analysis

    /// Runs the full NL analysis pipeline on the given text.
    private func analyzeText(_ text: String) -> TextAnalysis {
        let sentimentScore = measureSentiment(text)

        languageRecognizer?.reset()
        languageRecognizer?.processString(text)
        let language = languageRecognizer?.dominantLanguage

        var nouns: [String] = []
        var verbs: [String] = []
        var adjectives: [String] = []

        if let tagger {
            tagger.string = text
            let range = text.startIndex..<text.endIndex

            tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
                guard let tag else { return true }
                let word = String(text[tokenRange]).lowercased()
                switch tag {
                case .noun:       nouns.append(word)
                case .verb:       verbs.append(word)
                case .adjective:  adjectives.append(word)
                default: break
                }
                return true
            }
        }

        let words = text.split(whereSeparator: { $0.isWhitespace || $0.isNewline })
        let wordCount = words.count
        let uniqueWords = Set(words.map { $0.lowercased() })

        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let sentenceCount = max(sentences.count, 1)
        let avgSentenceLength = Double(wordCount) / Double(sentenceCount)

        let diversity = wordCount > 0 ? Double(uniqueWords.count) / Double(wordCount) : 0

        let mood: String
        switch sentimentScore {
        case 0.3...:         mood = "positive"
        case ..<(-0.3):      mood = "negative"
        default:             mood = "neutral"
        }

        return TextAnalysis(
            language: language,
            sentimentScore: sentimentScore,
            dominantMood: mood,
            keyNouns: Array(Set(nouns).prefix(10)),
            keyVerbs: Array(Set(verbs).prefix(8)),
            keyAdjectives: Array(Set(adjectives).prefix(8)),
            sentenceCount: sentenceCount,
            wordCount: wordCount,
            uniqueWordCount: uniqueWords.count,
            averageSentenceLength: avgSentenceLength,
            vocabularyDiversity: diversity
        )
    }

    /// Returns a sentiment score in `-1…1` using `NLTagger` with `.sentimentScore`.
    private func measureSentiment(_ text: String) -> Double {
        guard let sentimentTagger else { return 0 }
        sentimentTagger.string = text
        let range = text.startIndex..<text.endIndex
        var total = 0.0
        var count = 0

        sentimentTagger.enumerateTags(in: range, unit: .paragraph, scheme: .sentimentScore) { tag, _ in
            if let tag, let score = Double(tag.rawValue) {
                total += score
                count += 1
            }
            return true
        }
        return count > 0 ? total / Double(count) : 0
    }

    // MARK: - Private – Suggestion Builders

    /// Builds a single suggestion string for the given type, analysis, and personality.
    private func buildSuggestion(
        type: SuggestionType,
        analysis: TextAnalysis,
        text: String,
        personality: GhostPersonality
    ) -> String {
        let themePhrase = topicPhrase(from: analysis)
        let traitSet = Set(personality.traits)
        let isEncouraging = traitSet.contains("encouraging") || traitSet.contains("playful")
        let isCritical = traitSet.contains("critical") || traitSet.contains("analytical")
        let isVerbose = traitSet.contains("verbose") || traitSet.contains("freeform")

        switch type {
        case .continuation:
            return buildContinuationSuggestion(
                analysis: analysis, themePhrase: themePhrase,
                isEncouraging: isEncouraging, isVerbose: isVerbose
            )
        case .challenge:
            return buildChallengeSuggestion(
                analysis: analysis, themePhrase: themePhrase,
                isCritical: isCritical
            )
        case .summary:
            return buildSummarySuggestion(analysis: analysis, themePhrase: themePhrase)
        case .reframe:
            return buildReframeSuggestion(
                analysis: analysis, themePhrase: themePhrase,
                isEncouraging: isEncouraging
            )
        case .expand:
            return buildExpandSuggestion(
                analysis: analysis, text: text, themePhrase: themePhrase,
                isVerbose: isVerbose
            )
        }
    }

    private func buildContinuationSuggestion(
        analysis: TextAnalysis, themePhrase: String,
        isEncouraging: Bool, isVerbose: Bool
    ) -> String {
        var parts: [String] = []

        if analysis.sentimentScore > 0.2 {
            parts.append("The positive energy here is compelling.")
        } else if analysis.sentimentScore < -0.2 {
            parts.append("There's a raw tension in this passage that works.")
        }

        if !themePhrase.isEmpty {
            parts.append("Building on \(themePhrase), consider where this thread leads next.")
        } else {
            parts.append("Continue developing this line of thought — the direction is emerging.")
        }

        if isEncouraging {
            parts.append("You're onto something; let the momentum carry you forward.")
        }

        if isVerbose, !analysis.keyAdjectives.isEmpty {
            let adj = analysis.keyAdjectives.prefix(3).joined(separator: ", ")
            parts.append("The descriptive choices (\(adj)) set a strong tone — lean into them.")
        }

        if analysis.wordCount < 30 {
            parts.append("A few more sentences will give this idea room to breathe.")
        }

        return parts.joined(separator: " ")
    }

    private func buildChallengeSuggestion(
        analysis: TextAnalysis, themePhrase: String,
        isCritical: Bool
    ) -> String {
        var parts: [String] = []

        if analysis.vocabularyDiversity < 0.5 {
            parts.append("The vocabulary feels somewhat repetitive — introducing sharper word choices could add depth.")
        }

        if analysis.averageSentenceLength > 25 {
            parts.append("Several sentences run long. Breaking them up would sharpen the rhythm.")
        } else if analysis.averageSentenceLength < 8 {
            parts.append("The sentences are terse. Combining a few could create more flowing prose.")
        }

        if !themePhrase.isEmpty {
            parts.append("You lean heavily on \(themePhrase). What happens if you flip the perspective entirely?")
        }

        if isCritical {
            parts.append("Ask yourself: does every sentence earn its place? Cut anything that doesn't.")
        } else {
            parts.append("Try questioning the core assumption behind this passage — where does that lead?")
        }

        if analysis.sentimentScore > 0.4 {
            parts.append("The tone stays consistently upbeat. A moment of contrast could make it more compelling.")
        } else if analysis.sentimentScore < -0.4 {
            parts.append("The dark tone is effective, but a glimmer of light would give readers something to hold onto.")
        }

        return parts.joined(separator: " ")
    }

    private func buildSummarySuggestion(
        analysis: TextAnalysis, themePhrase: String
    ) -> String {
        var parts: [String] = []

        parts.append("So far, this piece spans \(analysis.sentenceCount) sentence\(analysis.sentenceCount == 1 ? "" : "s") with \(analysis.wordCount) words.")

        if !themePhrase.isEmpty {
            parts.append("The central thread revolves around \(themePhrase).")
        }

        let moodLabel: String
        switch analysis.dominantMood {
        case "positive": moodLabel = "optimistic and forward-looking"
        case "negative": moodLabel = "contemplative and intense"
        default:         moodLabel = "measured and exploratory"
        }
        parts.append("The overall tone feels \(moodLabel).")

        if analysis.vocabularyDiversity > 0.7 {
            parts.append("Vocabulary is rich and varied, which keeps the reader engaged.")
        } else if analysis.vocabularyDiversity < 0.4 {
            parts.append("Word variety is on the lower side — diversifying could strengthen the piece.")
        }

        return parts.joined(separator: " ")
    }

    private func buildReframeSuggestion(
        analysis: TextAnalysis, themePhrase: String,
        isEncouraging: Bool
    ) -> String {
        var parts: [String] = []

        if !analysis.keyNouns.isEmpty {
            let noun = analysis.keyNouns.first!
            parts.append("What if \"\(noun)\" isn't the subject but the obstacle? Rewriting from that angle could unlock a fresh layer.")
        }

        if analysis.sentimentScore > 0 {
            parts.append("Try expressing this same idea through loss or absence — the contrast often reveals hidden meaning.")
        } else {
            parts.append("Consider retelling this from a place of hope or discovery — it may surface nuances the current frame obscures.")
        }

        if !themePhrase.isEmpty {
            parts.append("Instead of centering \(themePhrase), make it the background. What moves to the foreground?")
        }

        if isEncouraging {
            parts.append("Reframing is where breakthrough ideas hide — trust the process.")
        }

        return parts.joined(separator: " ")
    }

    private func buildExpandSuggestion(
        analysis: TextAnalysis, text: String, themePhrase: String,
        isVerbose: Bool
    ) -> String {
        var parts: [String] = []

        if analysis.keyAdjectives.count < 3 {
            parts.append("The passage is light on descriptive detail. Adding sensory language — sounds, textures, colors — would make the scene vivid.")
        }

        if analysis.sentenceCount < 3 {
            parts.append("This reads as a seed. Expand with supporting examples or a short anecdote that grounds the idea.")
        }

        if !analysis.keyVerbs.isEmpty {
            let verb = analysis.keyVerbs.first!
            parts.append("The action \"\(verb)\" anchors the passage. Explore what led up to it and what follows.")
        }

        if !themePhrase.isEmpty {
            parts.append("Dig deeper into \(themePhrase): what are the stakes, the history, the emotional weight?")
        }

        if isVerbose {
            parts.append("Don't hold back — let the details cascade. Readers of this style crave immersion.")
        } else {
            parts.append("Even a concise expansion — two or three precise sentences — can double the impact.")
        }

        return parts.joined(separator: " ")
    }

    // MARK: - Private – Text Continuation Builder

    /// Builds a full text continuation (used by `generateText`).
    private func buildContinuation(
        from analysis: TextAnalysis,
        text: String,
        personality: GhostPersonality
    ) -> String {
        let themePhrase = topicPhrase(from: analysis)
        let traitSet = Set(personality.traits)

        var parts: [String] = []

        // Style prefix
        if traitSet.contains("encouraging") || traitSet.contains("playful") {
            parts.append("Great momentum here!")
        } else if traitSet.contains("critical") {
            parts.append("Let's sharpen this.")
        } else if traitSet.contains("analytical") {
            parts.append("Looking at the structure:")
        }

        // Theme-aware core
        if !themePhrase.isEmpty {
            parts.append("Continuing with \(themePhrase) —")
        }

        // Sentiment-guided direction
        switch analysis.dominantMood {
        case "positive":
            parts.append("the energy lifts the reader forward. Next, ground this optimism with a concrete detail or example that makes it tangible.")
        case "negative":
            parts.append("the weight of the tone pulls the reader in. Follow through by revealing what's at stake — let the tension serve a purpose.")
        default:
            parts.append("there's room to push in either direction. Choose a clear emotional vector for the next beat — it will give the reader something to hold onto.")
        }

        // Structural advice based on personality
        if traitSet.contains("verbose") || traitSet.contains("freeform") {
            if analysis.sentenceCount > 5 {
                parts.append("You have the space — let the next paragraph breathe with longer, layered sentences.")
            }
        } else if traitSet.contains("concise") || traitSet.contains("structured") {
            parts.append("Keep the next addition tight — one strong image or idea per sentence.")
        }

        return parts.joined(separator: " ")
    }

    // MARK: - Private – Helpers

    /// Produces a short phrase describing the dominant topic based on extracted nouns.
    private func topicPhrase(from analysis: TextAnalysis) -> String {
        let nouns = analysis.keyNouns.prefix(3)
        guard !nouns.isEmpty else { return "" }
        if nouns.count == 1 { return "the theme of \"\(nouns.first!)\"" }
        let joined = nouns.dropLast().joined(separator: ", ")
        return "themes of \(joined) and \(nouns.last!)"
    }
}
