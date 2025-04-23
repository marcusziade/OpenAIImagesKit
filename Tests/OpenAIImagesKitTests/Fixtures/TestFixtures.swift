import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import OpenAIImagesKit

enum TestFixtures {
    static let validAPIKey = "test-api-key"
    
    // Create image response
    static let createImageSuccessData = """
    {
        "created": 1677254147,
        "data": [
            {
                "url": "https://example.com/image.png",
                "revised_prompt": "A cute baby sea otter floating on its back in blue water."
            }
        ]
    }
    """.data(using: .utf8)!
    
    static let createImageSuccessDataB64 = """
    {
        "created": 1677254147,
        "data": [
            {
                "b64_json": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==",
                "revised_prompt": "A cute baby sea otter floating on its back in blue water."
            }
        ]
    }
    """.data(using: .utf8)!
    
    // Image edit response
    static let imageEditSuccessData = """
    {
        "created": 1677254147,
        "data": [
            {
                "url": "https://example.com/edited-image.png"
            }
        ]
    }
    """.data(using: .utf8)!
    
    // Image variation response
    static let imageVariationSuccessData = """
    {
        "created": 1677254147,
        "data": [
            {
                "url": "https://example.com/variation-image.png"
            }
        ]
    }
    """.data(using: .utf8)!
    
    // Error response
    static let errorResponseData = """
    {
        "error": {
            "message": "Incorrect API key provided",
            "type": "invalid_request_error",
            "param": null,
            "code": "invalid_api_key"
        }
    }
    """.data(using: .utf8)!
    
    // Generate a mock HTTP response
    static func mockHTTPResponse(url: URL, statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
    }
    
    // Sample image data (1x1 transparent PNG)
    static let sampleImageData = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")!
}