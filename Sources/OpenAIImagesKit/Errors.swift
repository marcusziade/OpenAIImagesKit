import Foundation

public enum OpenAIImagesError: Error {
    case invalidAPIKey
    case invalidRequest
    case failedToEncodeRequest
    case failedToEncodeImage
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case apiError(String, Int)
    case rateLimitExceeded
    case unexpectedError(String)
    
    public var localizedDescription: String {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key provided"
        case .invalidRequest:
            return "The request was invalid"
        case .failedToEncodeRequest:
            return "Failed to encode request"
        case .failedToEncodeImage:
            return "Failed to encode image to base64"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from the server"
        case .decodingError(let error):
            return "Error decoding response: \(error.localizedDescription)"
        case .apiError(let message, let code):
            return "API error (\(code)): \(message)"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .unexpectedError(let message):
            return "Unexpected error: \(message)"
        }
    }
}

// API Error Response
struct OpenAIErrorResponse: Codable {
    struct ErrorDetails: Codable {
        let message: String
        let type: String?
        let param: String?
        let code: String?
    }
    
    let error: ErrorDetails
}