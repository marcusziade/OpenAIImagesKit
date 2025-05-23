import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
@testable import OpenAIImagesKit

class MockNetworkSession: NetworkSessionProtocol {
    var requestHandler: ((URL, String, [String: String], Data?) -> (Data?, HTTPURLResponse?, Error?))?
    
    // MARK: - Callback-based API
    
    func performRequest<T: Decodable>(
        url: URL,
        method: String,
        headers: [String: String],
        body: Data?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        if let handler = requestHandler {
            let (data, response, error) = handler(url, method, headers, body)
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response else {
                completion(.failure(OpenAIImagesError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(OpenAIImagesError.invalidResponse))
                return
            }
            
            if httpResponse.statusCode >= 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(OpenAIErrorResponse.self, from: data)
                    completion(.failure(OpenAIImagesError.apiError(errorResponse.error.message, httpResponse.statusCode)))
                } catch {
                    if httpResponse.statusCode == 429 {
                        completion(.failure(OpenAIImagesError.rateLimitExceeded))
                    } else {
                        let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                        completion(.failure(OpenAIImagesError.apiError(message, httpResponse.statusCode)))
                    }
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(OpenAIImagesError.decodingError(error)))
            }
        } else {
            XCTFail("No request handler set for mock network session")
            completion(.failure(OpenAIImagesError.unexpectedError("No request handler set for mock network session")))
        }
    }
    
    // MARK: - Async/Await API
    
    func performRequest<T: Decodable>(
        url: URL, 
        method: String, 
        headers: [String: String], 
        body: Data?
    ) async throws -> T {
        guard let handler = requestHandler else {
            XCTFail("No request handler set for mock network session")
            throw OpenAIImagesError.unexpectedError("No request handler set for mock network session")
        }
        
        let (data, response, error) = handler(url, method, headers, body)
        
        if let error = error {
            throw error
        }
        
        guard let httpResponse = response else {
            throw OpenAIImagesError.invalidResponse
        }
        
        guard let data = data else {
            throw OpenAIImagesError.invalidResponse
        }
        
        if httpResponse.statusCode >= 400 {
            do {
                let errorResponse = try JSONDecoder().decode(OpenAIErrorResponse.self, from: data)
                throw OpenAIImagesError.apiError(errorResponse.error.message, httpResponse.statusCode)
            } catch {
                if httpResponse.statusCode == 429 {
                    throw OpenAIImagesError.rateLimitExceeded
                } else {
                    let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw OpenAIImagesError.apiError(message, httpResponse.statusCode)
                }
            }
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw OpenAIImagesError.decodingError(error)
        }
    }
}