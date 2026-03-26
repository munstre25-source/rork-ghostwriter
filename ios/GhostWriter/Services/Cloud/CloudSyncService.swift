import Foundation
import Observation

// MARK: - SyncState

/// The current state of the cloud synchronization engine.
enum SyncState: String, Sendable {
    case idle
    case syncing
    case synced
    case error
}

// MARK: - SyncError

/// Errors that can occur during cloud synchronization.
enum SyncError: Error, LocalizedError, Sendable {
    case syncFailed
    case conflictResolutionFailed
    case networkUnavailable
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .syncFailed:               "Cloud sync failed."
        case .conflictResolutionFailed: "Failed to resolve sync conflicts."
        case .networkUnavailable:       "Network is unavailable for sync."
        case .unauthorized:             "Cloud sync authorization failed."
        }
    }
}

// MARK: - CloudSyncService

/// Manages cloud synchronization of creative data.
///
/// Mock implementation that simulates sync operations. The architecture
/// is ready for CloudKit integration.
@Observable
final class CloudSyncService: @unchecked Sendable {

    /// The current synchronization state.
    var syncState: SyncState = .idle

    /// The date of the last successful sync, or `nil` if never synced.
    var lastSyncDate: Date?

    private var pendingItems: [Any] = []

    /// Performs a full sync cycle with the cloud backend.
    ///
    /// - Throws: ``SyncError/syncFailed`` if the operation cannot complete.
    func sync() async throws {
        guard syncState != .syncing else { return }

        syncState = .syncing

        do {
            try await Task.sleep(for: .seconds(Double.random(in: 1.0...3.0)))
            pendingItems.removeAll()
            lastSyncDate = .now
            syncState = .synced
            print("[CloudSync] Sync completed at \(Date.now)")
        } catch {
            syncState = .error
            throw SyncError.syncFailed
        }
    }

    /// Adds an item to the pending sync queue.
    ///
    /// Items in the queue will be pushed to the cloud on the next ``sync()`` call.
    ///
    /// - Parameter item: The item to queue for synchronization.
    func queueForSync(_ item: Any) {
        pendingItems.append(item)
        print("[CloudSync] Queued item for sync (\(pendingItems.count) pending)")
    }

    /// Resolves any detected conflicts between local and remote data.
    ///
    /// Uses a last-writer-wins strategy as a placeholder.
    func resolveConflicts() async {
        try? await Task.sleep(for: .seconds(Double.random(in: 0.5...1.0)))
        print("[CloudSync] Conflicts resolved (last-writer-wins strategy)")
    }
}
