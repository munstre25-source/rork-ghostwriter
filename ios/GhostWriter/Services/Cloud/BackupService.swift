import Foundation
import Observation

// MARK: - BackupInfo

/// Metadata describing a stored backup.
struct BackupInfo: Identifiable, Sendable {

    /// Unique identifier for this backup.
    var id: UUID

    /// When this backup was created.
    var createdAt: Date

    /// The size of the backup in bytes.
    var sizeInBytes: Int64

    /// A human-readable label for the backup.
    var label: String

    /// Whether this backup includes session data.
    var includesSessions: Bool

    /// Whether this backup includes personality data.
    var includesPersonalities: Bool
}

// MARK: - BackupError

/// Errors that can occur during backup operations.
enum BackupError: Error, LocalizedError, Sendable {
    case backupCreationFailed
    case restoreFailed
    case noBackupsAvailable
    case corruptedBackup

    var errorDescription: String? {
        switch self {
        case .backupCreationFailed: "Failed to create backup."
        case .restoreFailed:        "Failed to restore from backup."
        case .noBackupsAvailable:   "No backups are available."
        case .corruptedBackup:      "The backup data is corrupted."
        }
    }
}

// MARK: - BackupService

/// Manages local and cloud backup creation and restoration.
///
/// Mock implementation that simulates backup operations. Ready for
/// CloudKit or local file-based backup integration.
@Observable
final class BackupService: @unchecked Sendable {

    /// The date of the last successful backup, or `nil` if never backed up.
    var lastBackupDate: Date?

    private var storedBackups: [BackupInfo] = []

    /// Creates a new backup of all user data.
    ///
    /// - Throws: ``BackupError/backupCreationFailed`` if the backup cannot be created.
    func createBackup() async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 1.0...3.0)))

        let backup = BackupInfo(
            id: UUID(),
            createdAt: .now,
            sizeInBytes: Int64.random(in: 50_000...5_000_000),
            label: "Backup \(DateFormatter.localizedString(from: .now, dateStyle: .short, timeStyle: .short))",
            includesSessions: true,
            includesPersonalities: true
        )

        storedBackups.insert(backup, at: 0)
        lastBackupDate = .now
        print("[Backup] Created backup: \(backup.label) (\(backup.sizeInBytes) bytes)")
    }

    /// Restores user data from the most recent backup.
    ///
    /// - Throws: ``BackupError/noBackupsAvailable`` if no backups exist,
    ///   or ``BackupError/restoreFailed`` if restoration fails.
    func restoreFromBackup() async throws {
        guard let latest = storedBackups.first else {
            throw BackupError.noBackupsAvailable
        }

        try await Task.sleep(for: .seconds(Double.random(in: 1.5...4.0)))
        print("[Backup] Restored from backup: \(latest.label)")
    }

    /// Lists all available backups, most recent first.
    ///
    /// - Returns: An array of ``BackupInfo`` records.
    func listBackups() async -> [BackupInfo] {
        try? await Task.sleep(for: .seconds(Double.random(in: 0.3...0.8)))

        if storedBackups.isEmpty {
            storedBackups = (0..<3).map { i in
                BackupInfo(
                    id: UUID(),
                    createdAt: Calendar.current.date(byAdding: .day, value: -i * 7, to: .now) ?? .now,
                    sizeInBytes: Int64.random(in: 50_000...5_000_000),
                    label: "Auto-backup \(i + 1)",
                    includesSessions: true,
                    includesPersonalities: i == 0
                )
            }
        }

        return storedBackups
    }
}
