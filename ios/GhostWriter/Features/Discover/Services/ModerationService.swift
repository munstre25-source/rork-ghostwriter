import Foundation
import Observation

/// Handles report/block actions for public discovery content.
@Observable
final class ModerationService: @unchecked Sendable {
    private(set) var blockedCreatorIds: Set<UUID> = []

    func reportContent(itemId: UUID, reason: String) async {
        _ = itemId
        _ = reason
        try? await Task.sleep(for: .milliseconds(120))
    }

    func blockCreator(_ creatorId: UUID) {
        blockedCreatorIds.insert(creatorId)
    }

    func isBlocked(_ creatorId: UUID) -> Bool {
        blockedCreatorIds.contains(creatorId)
    }
}
