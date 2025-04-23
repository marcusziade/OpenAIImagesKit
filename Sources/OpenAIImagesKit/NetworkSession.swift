import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol NetworkSessionProtocol {
    func performRequest<T: Decodable>(
        url: URL,
        method: String,
        headers: [String: String],
        body: Data?,
        completion: @escaping (Result<T, Error>) -> Void
    )
    
    func performRequest<T: Decodable>(
        url: URL,
        method: String,
        headers: [String: String],
        body: Data?
    ) async throws -> T
}

public class NetworkSession: NetworkSessionProtocol {
    // MARK: - Callback-based API
    
    public func performRequest<T: Decodable>(
        url: URL,
        method: String,
        headers: [String: String],
        body: Data?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        Task {
            do {
                let result = try await performRequest(url: url, method: method, headers: headers, body: body) as T
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Async/Await API
    
    public func performRequest<T: Decodable>(
        url: URL,
        method: String,
        headers: [String: String],
        body: Data?
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        #if canImport(FoundationNetworking)
        // For platforms without native URLSession async/await support (Linux)
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: OpenAIImagesError.networkError(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    continuation.resume(throwing: OpenAIImagesError.invalidResponse)
                    return
                }
                
                guard let data = data else {
                    continuation.resume(throwing: OpenAIImagesError.invalidResponse)
                    return
                }
                
                // Handle API errors
                if httpResponse.statusCode >= 400 {
                    do {
                        let errorResponse = try JSONDecoder().decode(OpenAIErrorResponse.self, from: data)
                        continuation.resume(throwing: OpenAIImagesError.apiError(errorResponse.error.message, httpResponse.statusCode))
                    } catch {
                        // If we can't decode an error response, return the status code
                        if httpResponse.statusCode == 429 {
                            continuation.resume(throwing: OpenAIImagesError.rateLimitExceeded)
                        } else {
                            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                            continuation.resume(throwing: OpenAIImagesError.apiError(message, httpResponse.statusCode))
                        }
                    }
                    return
                }
                
                // Decode successful response
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    continuation.resume(returning: decodedResponse)
                } catch {
                    continuation.resume(throwing: OpenAIImagesError.decodingError(error))
                }
            }
            
            task.resume()
        }
        #else
        // For platforms with native URLSession async/await support (macOS, iOS)
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenAIImagesError.invalidResponse
            }
            
            // Handle API errors
            if httpResponse.statusCode >= 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(OpenAIErrorResponse.self, from: data)
                    throw OpenAIImagesError.apiError(errorResponse.error.message, httpResponse.statusCode)
                } catch {
                    // If we can't decode an error response, return the status code
                    if httpResponse.statusCode == 429 {
                        throw OpenAIImagesError.rateLimitExceeded
                    } else {
                        let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                        throw OpenAIImagesError.apiError(message, httpResponse.statusCode)
                    }
                }
            }
            
            // Decode successful response
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw OpenAIImagesError.decodingError(error)
            }
        } catch let networkError as URLError {
            throw OpenAIImagesError.networkError(networkError)
        }
        #endif
    }
}