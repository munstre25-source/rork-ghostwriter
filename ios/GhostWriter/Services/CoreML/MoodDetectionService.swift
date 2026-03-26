import Foundation
import NaturalLanguage
import SwiftUI
import Observation

// MARK: - DetectedMood

/// A mood detected from the user's writing behavior and text content.
enum DetectedMood: String, CaseIterable, Identifiable, Codable, Sendable {
    case focused
    case frustrated
    case creative
    case tired
    case excited

    var id: String { rawValue }

    /// A human-readable label for display in the UI.
    var displayName: String {
        switch self {
        case .focused:     "Focused"
        case .frustrated:  "Frustrated"
        case .creative:    "Creative"
        case .tired:       "Tired"
        case .excited:     "Excited"
        }
    }

    /// The accent color associated with this mood.
    var color: Color {
        switch self {
        case .focused:     .blue
        case .frustrated:  .red
        case .creative:    .purple
        case .tired:       .gray
        case .excited:     .orange
        }
    }

    /// An SF Symbol representing this mood.
    var icon: String {
        switch self {
        case .focused:     "eye.fill"
        case .frustrated:  "exclamationmark.triangle.fill"
        case .creative:    "sparkles"
        case .tired:       "moon.fill"
        case .excited:     "bolt.fill"
        }
    }
}

// MARK: - TypingBehaviorSnapshot

/// A lightweight snapshot of the user's typing cadence at analysis time.
private struct TypingBehaviorSnapshot: Sendable {
    let charsPerSecond: Double
    let averagePauseBetweenBursts: Double
}

// MARK: - MoodDetectionService

/// Detects user mood from text content and typing behavior using Apple's
/// NaturalLanguage framework.
///
/// Mood is derived from three complementary signals:
/// 1. **NL sentiment analysis** — `NLTagger` with `.sentimentScore` provides a
///    machine-learned sentiment value for each paragraph.
/// 2. **Keyword heuristics** — domain-specific word lists add granularity beyond
///    positive/negative polarity.
/// 3. **Typing cadence** — characters-per-second and pause duration map to
///    energy and focus levels.
///
/// ## Usage
/// ```swift
/// let service = MoodDetectionService()
/// let mood = await service.analyzeMood(
///     from: "I'm stuck and nothing is working…",
///     typingSpeed: 1.2,
///     pauseDuration: 8.0
/// )
/// // mood == .frustrated
/// ```
@Observable
final class MoodDetectionService: @unchecked Sendable {

    // MARK: Public state

    /// The most recently detected mood, or `nil` if no analysis has been performed.
    var currentMood: DetectedMood?

    // MARK: Private NL resources

    private let sentimentTagger = NLTagger(tagSchemes: [.sentimentScore])

    private let moodKeywords: [DetectedMood: [String]] = [
        .focused:    ["therefore", "specifically", "precisely", "importantly", "clearly", "notably",
                      "objective", "goal", "plan", "define", "analyze", "detail"],
        .frustrated: ["ugh", "frustrated", "stuck", "can't", "annoying", "wrong", "terrible",
                      "hate", "impossible", "fail", "broken", "hopeless", "struggle"],
        .creative:   ["imagine", "wonder", "perhaps", "magical", "dream", "inspire", "wild",
                      "vision", "spark", "muse", "flow", "create", "invent", "explore"],
        .tired:      ["tired", "exhausted", "later", "maybe", "whatever", "sleepy", "done",
                      "enough", "boring", "slow", "nap", "rest", "sigh"],
        .excited:    ["amazing", "wow", "incredible", "love", "brilliant", "fantastic", "yes",
                      "awesome", "thrilling", "breakthrough", "perfect", "ecstatic"]
    ]

    // MARK: - analyzeMood

    /// Analyzes the user's mood by combining NL sentiment, keyword signals,
    /// and typing cadence.
    ///
    /// - Parameters:
    ///   - text: The user's current text content.
    ///   - typingSpeed: Characters per second the user is typing.
    ///   - pauseDuration: Average pause duration between typing bursts, in seconds.
    /// - Returns: The detected ``DetectedMood``.
    func analyzeMood(
        from text: String,
        typingSpeed: Double,
        pauseDuration: Double
    ) async -> DetectedMood {
        let behavior = TypingBehaviorSnapshot(
            charsPerSecond: typingSpeed,
            averagePauseBetweenBursts: pauseDuration
        )

        let sentimentValue = nlSentiment(for: text)
        let keywordScores = keywordAnalysis(of: text)
        let cadenceScores = cadenceSignals(from: behavior)

        var combined: [DetectedMood: Double] = [:]
        for mood in DetectedMood.allCases {
            let sentimentContribution = sentimentWeight(sentimentValue, for: mood)
            let keywordContribution = keywordScores[mood, default: 0]
            let cadenceContribution = cadenceScores[mood, default: 0]

            combined[mood] = sentimentContribution * 0.40
                + keywordContribution * 0.35
                + cadenceContribution * 0.25
        }

        let detected = combined.max(by: { $0.value < $1.value })?.key ?? .focused
        currentMood = detected
        return detected
    }

    // MARK: - suggestPersonality

    /// Suggests a built-in ghost personality name best suited to the detected mood.
    ///
    /// - Parameter mood: The detected mood to match against.
    /// - Returns: The name of a recommended built-in personality.
    func suggestPersonality(for mood: DetectedMood) -> String {
        switch mood {
        case .focused:     "The Architect"
        case .frustrated:  "The Muse"
        case .creative:    "The Visionary"
        case .tired:       "The Muse"
        case .excited:     "The Critic"
        }
    }

    // MARK: - Private – NL Sentiment

    /// Returns the average paragraph-level sentiment score in `-1…1`.
    private func nlSentiment(for text: String) -> Double {
        sentimentTagger.string = text
        let range = text.startIndex..<text.endIndex

        var total = 0.0
        var count = 0

        sentimentTagger.enumerateTags(
            in: range,
            unit: .paragraph,
            scheme: .sentimentScore
        ) { tag, _ in
            if let tag, let score = Double(tag.rawValue) {
                total += score
                count += 1
            }
            return true
        }

        return count > 0 ? total / Double(count) : 0
    }

    // MARK: - Private – Keyword Analysis

    /// Scores each mood by counting matching keywords in the text.
    /// Normalizes so the highest-scoring mood reaches ~1.0.
    private func keywordAnalysis(of text: String) -> [DetectedMood: Double] {
        let lowercased = text.lowercased()
        let words = Set(lowercased.split(whereSeparator: { !$0.isLetter }).map(String.init))

        var raw: [DetectedMood: Double] = [:]
        for mood in DetectedMood.allCases {
            let keywords = moodKeywords[mood] ?? []
            let hits = keywords.reduce(0.0) { total, keyword in
                total + (words.contains(keyword) ? 1.0 : 0.0)
            }
            raw[mood] = hits
        }

        let maxHits = raw.values.max() ?? 1
        let normalizer = maxHits > 0 ? maxHits : 1

        return raw.mapValues { $0 / normalizer }
    }

    // MARK: - Private – Cadence Signals

    /// Maps typing speed and pause duration to mood-likelihood scores.
    private func cadenceSignals(from behavior: TypingBehaviorSnapshot) -> [DetectedMood: Double] {
        var scores: [DetectedMood: Double] = Dictionary(
            uniqueKeysWithValues: DetectedMood.allCases.map { ($0, 0.0) }
        )

        let speed = behavior.charsPerSecond
        let pause = behavior.averagePauseBetweenBursts

        // High speed → excited or focused
        if speed > 5.0 {
            scores[.excited] = 1.0
            scores[.focused] = 0.6
        } else if speed > 3.0 {
            scores[.focused] = 1.0
            scores[.creative] = 0.5
        } else if speed > 1.5 {
            scores[.creative] = 0.8
            scores[.focused] = 0.5
        } else {
            scores[.tired] = 0.9
            scores[.frustrated] = 0.6
        }

        // Long pauses → tired or frustrated; short → focused or excited
        if pause > 8.0 {
            scores[.tired, default: 0] += 0.6
        } else if pause > 4.0 {
            scores[.frustrated, default: 0] += 0.5
            scores[.tired, default: 0] += 0.3
        } else if pause < 1.5 {
            scores[.focused, default: 0] += 0.5
            scores[.excited, default: 0] += 0.4
        } else {
            scores[.creative, default: 0] += 0.3
        }

        // Normalize to 0…1
        let maxVal = scores.values.max() ?? 1
        let normalizer = maxVal > 0 ? maxVal : 1
        return scores.mapValues { $0 / normalizer }
    }

    // MARK: - Private – Sentiment → Mood Mapping

    /// Converts an NL sentiment score into a per-mood weight.
    ///
    /// Positive sentiment boosts excited/creative/focused; negative boosts
    /// frustrated; near-zero favors focused/tired.
    private func sentimentWeight(_ sentiment: Double, for mood: DetectedMood) -> Double {
        switch mood {
        case .excited:
            return max(sentiment, 0)                        // 0…1
        case .creative:
            return max(sentiment * 0.8, 0)                  // 0…0.8
        case .focused:
            return 1.0 - abs(sentiment)                     // peaks near neutral
        case .frustrated:
            return max(-sentiment, 0)                       // 0…1 for negative
        case .tired:
            let neutrality = 1.0 - abs(sentiment)
            return neutrality * 0.6                         // mild boost near neutral
        }
    }
}
