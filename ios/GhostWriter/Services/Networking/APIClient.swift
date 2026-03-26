import Foundation
import Observation

// MARK: - APIError

/// Errors that can occur during network requests.
enum APIError: Error, LocalizedError, Sendable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(Error)
    case encodingFailed
    case networkUnavailable
    case unauthorized
    case rateLimited
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidURL:               "The request URL is invalid."
        case .invalidResponse:          "The server returned an invalid response."
        case .httpError(let code):      "HTTP error \(code)."
        case .decodingFailed(let err):  "Failed to decode response: \(err.localizedDescription)"
        case .encodingFailed:           "Failed to encode request body."
        case .networkUnavailable:       "Network is unavailable."
        case .unauthorized:             "Authentication required."
        case .rateLimited:              "Rate limit exceeded. Please try again later."
        case .serverError:              "An internal server error occurred."
        }
    }
}

// MARK: - APIClient

/// HTTP client for communicating with the GhostWriter backend API.
///
/// Builds and executes typed requests against ``APIEndpoint`` definitions,
/// handling JSON encoding/decoding, authentication headers, and error mapping.
@Observable
final class APIClient: @unchecked Sendable {

    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    /// Creates a new API client.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for all API requests.
    ///   - session: The URL session to use. Defaults to `.shared`.
    init(
        baseURL: URL = URL(string: "https://api.ghostwriter.app/v1")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    /// Executes a typed API request and decodes the response.
    ///
    /// - Parameter endpoint: The endpoint to request.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: ``APIError`` if the request or decoding fails.
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let urlRequest = buildRequest(for: endpoint)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw APIError.unauthorized
        case 429:
            throw APIError.rateLimited
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    /// Uploads binary data to the specified endpoint.
    ///
    /// - Parameters:
    ///   - data: The data to upload.
    ///   - endpoint: The endpoint to upload to.
    /// - Returns: The remote URL of the uploaded resource.
    /// - Throws: ``APIError`` if the upload fails.
    func upload(data: Data, to endpoint: APIEndpoint) async throws -> URL {
        var urlRequest = buildRequest(for: endpoint)
        urlRequest.httpBody = data
        urlRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        let (responseData, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        struct UploadResponse: Decodable {
            let url: URL
        }

        let uploadResponse = try decoder.decode(UploadResponse.self, from: responseData)
        return uploadResponse.url
    }

    // MARK: - Private

    private func buildRequest(for endpoint: APIEndpoint) -> URLRequest {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.timeoutInterval = 30

        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}
