import Foundation
import Observation

/// Local analytics tracking service for creative session events.
///
/// Logs events to the console in debug builds. The interface is designed
/// for easy migration to a remote analytics backend.
@Observable
final class AnalyticsService: @unchecked Sendable {

    private var eventLog: [(name: String, properties: [String: String]?, timestamp: Date)] = []

    /// Tracks a named event with optional properties.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - properties: A dictionary of metadata to attach to the event.
    func trackEvent(_ name: String, properties: [String: Any]? = nil) {
        let stringProps = properties?.compactMapValues { "\($0)" }
        eventLog.append((name: name, properties: stringProps, timestamp: .now))
        print("[Analytics] \(name) | \(stringProps ?? [:])")
    }

    /// Tracks the start of a creative session.
    ///
    /// - Parameter type: The type of session being started.
    func trackSessionStart(type: SessionType) {
        trackEvent("session_start", properties: ["type": type.rawValue])
    }

    /// Tracks the end of a creative session with summary metrics.
    ///
    /// - Parameters:
    ///   - wordCount: Total words written during the session.
    ///   - flowScore: The user's flow score at session end.
    ///   - duration: Total session duration in seconds.
    func trackSessionEnd(wordCount: Int, flowScore: Double, duration: TimeInterval) {
        trackEvent("session_end", properties: [
            "word_count": wordCount,
            "flow_score": flowScore,
            "duration_seconds": Int(duration)
        ] as [String: Any])
    }

    /// Tracks acceptance of an AI suggestion.
    ///
    /// - Parameter suggestionId: The unique identifier of the accepted suggestion.
    func trackSuggestionAccepted(suggestionId: UUID) {
        trackEvent("suggestion_accepted", properties: ["suggestion_id": suggestionId.uuidString])
    }

    /// Tracks rejection of an AI suggestion.
    ///
    /// - Parameter suggestionId: The unique identifier of the rejected suggestion.
    func trackSuggestionRejected(suggestionId: UUID) {
        trackEvent("suggestion_rejected", properties: ["suggestion_id": suggestionId.uuidString])
    }

    /// Tracks creation of a new ghost clip.
    ///
    /// - Parameter clipId: The unique identifier of the created clip.
    func trackClipCreated(clipId: UUID) {
        trackEvent("clip_created", properties: ["clip_id": clipId.uuidString])
    }

    /// Tracks sharing of a ghost clip to an external platform.
    ///
    /// - Parameters:
    ///   - clipId: The unique identifier of the shared clip.
    ///   - platform: The platform the clip was shared to.
    func trackClipShared(clipId: UUID, platform: String) {
        trackEvent("clip_shared", properties: [
            "clip_id": clipId.uuidString,
            "platform": platform
        ])
    }
}
