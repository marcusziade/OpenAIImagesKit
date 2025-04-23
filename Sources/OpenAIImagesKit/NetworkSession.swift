import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

protocol NetworkSessionProtocol {
    func performRequest<T: Decodable>(
        url: URL,
        method: String,
        headers: [String: String],
        body: Data?,
        completion: @escaping (Result<T, Error>) -> Void
    )
}

class NetworkSession: NetworkSessionProtocol {
    func performRequest<T: Decodable>(
        url: URL,
        method: String,
        headers: [String: String],
        body: Data?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(OpenAIImagesError.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(OpenAIImagesError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(OpenAIImagesError.invalidResponse))
                return
            }
            
            // Handle API errors
            if httpResponse.statusCode >= 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(OpenAIErrorResponse.self, from: data)
                    completion(.failure(OpenAIImagesError.apiError(errorResponse.error.message, httpResponse.statusCode)))
                } catch {
                    // If we can't decode an error response, return the status code
                    if httpResponse.statusCode == 429 {
                        completion(.failure(OpenAIImagesError.rateLimitExceeded))
                    } else {
                        let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                        completion(.failure(OpenAIImagesError.apiError(message, httpResponse.statusCode)))
                    }
                }
                return
            }
            
            // Decode successful response
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(OpenAIImagesError.decodingError(error)))
            }
        }
        
        task.resume()
    }
}