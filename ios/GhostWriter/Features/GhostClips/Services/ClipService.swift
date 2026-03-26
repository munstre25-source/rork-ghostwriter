import Foundation
import Observation
import SwiftData

// MARK: - ClipError

/// Errors that can occur during clip operations.
enum ClipError: Error, LocalizedError, Sendable {
    case captureFailed
    case editFailed
    case shareFailed
    case deleteFailed
    case notFound
    case invalidDuration

    var errorDescription: String? {
        switch self {
        case .captureFailed:    "Failed to capture clip from session."
        case .editFailed:       "Failed to edit clip."
        case .shareFailed:      "Failed to share clip."
        case .deleteFailed:     "Failed to delete clip."
        case .notFound:         "Clip not found."
        case .invalidDuration:  "Invalid clip duration."
        }
    }
}

// MARK: - ClipService

/// Manages creation, editing, sharing, and deletion of ghost clips.
@Observable
final class ClipService: @unchecked Sendable {

    /// All clips owned by the current user.
    var userClips: [GhostClip] = []

    /// Captures a new clip from a creative session.
    ///
    /// - Parameters:
    ///   - session: The session to capture from.
    ///   - duration: The clip duration in seconds.
    /// - Returns: The newly created ``GhostClip``.
    /// - Throws: ``ClipError/invalidDuration`` if the duration is out of range,
    ///   or ``ClipError/captureFailed`` if capture fails.
    func captureClip(
        from session: CreativeSession,
        duration: Double
    ) async throws -> GhostClip {
        guard duration > 0 && duration <= 60 else {
            throw ClipError.invalidDuration
        }

        try await Task.sleep(for: .seconds(Double.random(in: 1.0...2.0)))

        let clip = GhostClip(
            sessionId: session.id,
            creatorId: session.userId,
            videoURL: URL(string: "https://clips.ghostwriter.app/\(UUID().uuidString).mp4")!,
            duration: duration,
            title: session.title ?? "Untitled Clip",
            personalityUsed: "The Muse"
        )

        userClips.insert(clip, at: 0)
        print("[Clips] Captured \(duration)s clip from session \(session.id)")
        return clip
    }

    /// Edits a clip's metadata.
    ///
    /// - Parameters:
    ///   - clip: The clip to edit.
    ///   - title: An optional new title.
    ///   - description: An optional new description.
    /// - Throws: ``ClipError/editFailed`` if the edit fails.
    func editClip(
        _ clip: GhostClip,
        title: String?,
        description: String?
    ) async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 0.3...0.8)))

        if let title { clip.title = title }
        if let description { clip.clipDescription = description }
        print("[Clips] Edited clip \(clip.id)")
    }

    /// Shares a clip to an external platform.
    ///
    /// - Parameters:
    ///   - clip: The clip to share.
    ///   - platform: The target platform name (e.g. "twitter", "instagram").
    /// - Throws: ``ClipError/shareFailed`` if sharing fails.
    func shareClip(_ clip: GhostClip, to platform: String) async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))

        clip.shareCount += 1
        print("[Clips] Shared clip \(clip.id) to \(platform)")
    }

    /// Fetches a clip by id from the SwiftData store.
    ///
    /// - Parameters:
    ///   - id: The clip identifier.
    ///   - context: Active model context.
    /// - Returns: The matching ``GhostClip``, if any.
    func clip(withId id: UUID, in context: ModelContext) throws -> GhostClip? {
        var descriptor = FetchDescriptor<GhostClip>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    /// Deletes a clip permanently.
    ///
    /// - Parameter clip: The clip to delete.
    /// - Throws: ``ClipError/notFound`` if the clip is not in the user's list.
    func deleteClip(_ clip: GhostClip) async throws {
        guard userClips.contains(where: { $0.id == clip.id }) else {
            throw ClipError.notFound
        }

        try await Task.sleep(for: .seconds(Double.random(in: 0.3...0.8)))

        userClips.removeAll { $0.id == clip.id }
        print("[Clips] Deleted clip \(clip.id)")
    }
}
