import Foundation
import Observation

// MARK: - StorageError

/// Errors that can occur during local file storage operations.
enum StorageError: Error, LocalizedError, Sendable {
    case saveFailed(Error)
    case loadFailed(Error)
    case deleteFailed(Error)
    case fileNotFound
    case directoryCreationFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed(let err):          "Failed to save data: \(err.localizedDescription)"
        case .loadFailed(let err):          "Failed to load data: \(err.localizedDescription)"
        case .deleteFailed(let err):        "Failed to delete data: \(err.localizedDescription)"
        case .fileNotFound:                 "The requested file was not found."
        case .directoryCreationFailed:      "Failed to create storage directory."
        }
    }
}

// MARK: - StorageService

/// Persistent local storage using the documents directory.
///
/// Stores and retrieves `Codable` values as JSON files keyed by string identifiers.
@Observable
final class StorageService: @unchecked Sendable {

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var storageDirectory: URL {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("GhostWriterData", isDirectory: true)
    }

    init() {
        ensureDirectoryExists()
    }

    /// Saves an encodable value to local storage.
    ///
    /// - Parameters:
    ///   - item: The value to persist.
    ///   - forKey: The storage key identifying this value.
    /// - Throws: ``StorageError/saveFailed(_:)`` if encoding or writing fails.
    func save<T: Encodable>(_ item: T, forKey key: String) throws {
        do {
            let data = try encoder.encode(item)
            let fileURL = storageDirectory.appendingPathComponent(sanitizedFileName(for: key))
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw StorageError.saveFailed(error)
        }
    }

    /// Loads a decodable value from local storage.
    ///
    /// - Parameter forKey: The storage key identifying the value to load.
    /// - Returns: The decoded value.
    /// - Throws: ``StorageError/fileNotFound`` if no file exists for the key,
    ///   or ``StorageError/loadFailed(_:)`` if decoding fails.
    func load<T: Decodable>(forKey key: String) throws -> T {
        let fileURL = storageDirectory.appendingPathComponent(sanitizedFileName(for: key))

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw StorageError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(T.self, from: data)
        } catch {
            throw StorageError.loadFailed(error)
        }
    }

    /// Deletes the file associated with a storage key.
    ///
    /// - Parameter forKey: The storage key to remove.
    /// - Throws: ``StorageError/deleteFailed(_:)`` if removal fails.
    func delete(forKey key: String) throws {
        let fileURL = storageDirectory.appendingPathComponent(sanitizedFileName(for: key))

        guard fileManager.fileExists(atPath: fileURL.path) else { return }

        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            throw StorageError.deleteFailed(error)
        }
    }

    /// Checks whether a file exists for the given storage key.
    ///
    /// - Parameter forKey: The storage key to check.
    /// - Returns: `true` if a file exists for the key.
    func fileExists(forKey key: String) -> Bool {
        let fileURL = storageDirectory.appendingPathComponent(sanitizedFileName(for: key))
        return fileManager.fileExists(atPath: fileURL.path)
    }

    // MARK: - Private

    private func ensureDirectoryExists() {
        if !fileManager.fileExists(atPath: storageDirectory.path) {
            try? fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        }
    }

    private func sanitizedFileName(for key: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let sanitized = key.unicodeScalars.filter { allowed.contains($0) }
        return String(String.UnicodeScalarView(sanitized)) + ".json"
    }
}
