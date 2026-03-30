import Foundation
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

// MARK: - MoodDetectionService

/// Detects user mood from text content and typing behavior.
///
/// Uses heuristic analysis of text sentiment, typing speed, and pause
/// patterns to infer the user's creative mood.
@Observable
final class MoodDetectionService: @unchecked Sendable {

    /// The most recently detected mood, or `nil` if no analysis has been performed.
    var currentMood: DetectedMood?

    private let moodKeywords: [DetectedMood: [String]] = [
        .focused:    ["therefore", "specifically", "precisely", "importantly", "clearly", "notably"],
        .frustrated: ["ugh", "frustrated", "stuck", "can't", "annoying", "wrong", "terrible", "hate"],
        .creative:   ["imagine", "wonder", "perhaps", "magical", "dream", "inspire", "wild", "vision"],
        .tired:      ["tired", "exhausted", "later", "maybe", "whatever", "sleepy", "done", "enough"],
        .excited:    ["amazing", "wow", "incredible", "love", "brilliant", "fantastic", "yes", "awesome"]
    ]

    /// Analyzes the user's mood from text content and typing behavior.
    ///
    /// - Parameters:
    ///   - text: The user's current text content.
    ///   - typingSpeed: Characters per second the user is typing.
    ///   - pauseDuration: Average pause duration between bursts, in seconds.
    /// - Returns: The detected mood.
    func analyzeMood(
        from text: String,
        typingSpeed: Double,
        pauseDuration: Double
    ) async -> DetectedMood {
        try? await Task.sleep(for: .seconds(Double.random(in: 0.3...0.8)))

        let lowercased = text.lowercased()
        var scores: [DetectedMood: Double] = [:]

        for mood in DetectedMood.allCases {
            let keywords = moodKeywords[mood] ?? []
            let keywordHits = keywords.reduce(0.0) { total, keyword in
                total + (lowercased.contains(keyword) ? 1.0 : 0.0)
            }
            scores[mood] = keywordHits
        }

        if typingSpeed > 5.0 {
            scores[.excited, default: 0] += 2.0
            scores[.focused, default: 0] += 1.0
        } else if typingSpeed < 1.5 {
            scores[.tired, default: 0] += 2.0
            scores[.frustrated, default: 0] += 1.0
        } else {
            scores[.focused, default: 0] += 1.5
            scores[.creative, default: 0] += 1.0
        }

        if pauseDuration > 5.0 {
            scores[.tired, default: 0] += 1.5
            scores[.frustrated, default: 0] += 1.0
        } else if pauseDuration < 1.0 {
            scores[.focused, default: 0] += 1.5
            scores[.excited, default: 0] += 1.0
        }

        let detected = scores.max(by: { $0.value < $1.value })?.key ?? .focused
        currentMood = detected
        return detected
    }

    /// Suggests a ghost personality name well-suited to the detected mood.
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
}
