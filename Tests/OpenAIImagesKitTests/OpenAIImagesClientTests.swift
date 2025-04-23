import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import OpenAIImagesKit

final class OpenAIImagesClientTests: XCTestCase {
    var mockNetworkSession: MockNetworkSession!
    var client: OpenAIImagesClient!
    
    override func setUp() {
        super.setUp()
        mockNetworkSession = MockNetworkSession()
        client = OpenAIImagesClient(apiKey: TestFixtures.validAPIKey, networkSession: mockNetworkSession)
    }
    
    override func tearDown() {
        mockNetworkSession = nil
        client = nil
        super.tearDown()
    }
    
    // MARK: - Create Image Tests
    
    func testCreateImageSuccess() {
        let expectation = expectation(description: "Create image request completes")
        
        // Set up mock response
        mockNetworkSession.requestHandler = { url, method, headers, body in
            XCTAssertEqual(url.absoluteString, "https://api.openai.com/v1/images/generations")
            XCTAssertEqual(method, "POST")
            XCTAssertEqual(headers["Authorization"], "Bearer \(TestFixtures.validAPIKey)")
            
            // Verify request body
            if let body = body, let requestString = String(data: body, encoding: .utf8) {
                XCTAssertTrue(requestString.contains("\"prompt\":"))
                XCTAssertTrue(requestString.contains("\"model\":"))
            } else {
                XCTFail("Invalid request body")
            }
            
            return (
                TestFixtures.createImageSuccessData,
                TestFixtures.mockHTTPResponse(url: url, statusCode: 200),
                nil
            )
        }
        
        // Make the request
        client.createImage(prompt: "A cute baby sea otter") { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.created, 1677254147)
                XCTAssertEqual(response.data.count, 1)
                XCTAssertEqual(response.data[0].url, "https://example.com/image.png")
                XCTAssertEqual(response.data[0].revisedPrompt, "A cute baby sea otter floating on its back in blue water.")
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreateImageWithB64Response() {
        let expectation = expectation(description: "Create image with b64_json response completes")
        
        mockNetworkSession.requestHandler = { url, method, headers, body in
            // Verify request body contains response_format: b64_json
            if let body = body, let requestString = String(data: body, encoding: .utf8) {
                XCTAssertTrue(requestString.contains("\"response_format\":\"b64_json\""))
            } else {
                XCTFail("Invalid request body")
            }
            
            return (
                TestFixtures.createImageSuccessDataB64,
                TestFixtures.mockHTTPResponse(url: url, statusCode: 200),
                nil
            )
        }
        
        client.createImage(
            prompt: "A cute baby sea otter",
            responseFormat: .b64Json
        ) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.data.count, 1)
                XCTAssertNotNil(response.data[0].b64Json)
                XCTAssertNil(response.data[0].url)
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreateImageError() {
        let expectation = expectation(description: "Create image request fails")
        
        mockNetworkSession.requestHandler = { url, method, headers, body in
            return (
                TestFixtures.errorResponseData,
                TestFixtures.mockHTTPResponse(url: url, statusCode: 401),
                nil
            )
        }
        
        client.createImage(prompt: "A cute baby sea otter") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                if case let OpenAIImagesError.apiError(message, code) = error {
                    XCTAssertEqual(message, "Incorrect API key provided")
                    XCTAssertEqual(code, 401)
                } else {
                    XCTFail("Expected API error but got: \(error)")
                }
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreateImageNetworkError() {
        let expectation = expectation(description: "Create image network error")
        let mockError = NSError(domain: "test", code: 999, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        
        mockNetworkSession.requestHandler = { url, method, headers, body in
            return (nil, nil, mockError)
        }
        
        client.createImage(prompt: "A cute baby sea otter") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                // Just check that we get some kind of error
                XCTAssertNotNil(error, "Expected an error")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: - Edit Image Tests
    
    func testEditImageSuccess() {
        let expectation = expectation(description: "Edit image request completes")
        
        mockNetworkSession.requestHandler = { url, method, headers, body in
            XCTAssertEqual(url.absoluteString, "https://api.openai.com/v1/images/edits")
            XCTAssertEqual(method, "POST")
            
            if let body = body, let requestString = String(data: body, encoding: .utf8) {
                XCTAssertTrue(requestString.contains("\"prompt\":"))
                XCTAssertTrue(requestString.contains("\"image\":"))
            } else {
                XCTFail("Invalid request body")
            }
            
            return (
                TestFixtures.imageEditSuccessData,
                TestFixtures.mockHTTPResponse(url: url, statusCode: 200),
                nil
            )
        }
        
        client.editImage(
            image: TestFixtures.sampleImageData,
            prompt: "Add a hat"
        ) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.data.count, 1)
                XCTAssertEqual(response.data[0].url, "https://example.com/edited-image.png")
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: - Create Image Variation Tests
    
    func testCreateImageVariationSuccess() {
        let expectation = expectation(description: "Create image variation request completes")
        
        mockNetworkSession.requestHandler = { url, method, headers, body in
            XCTAssertEqual(url.absoluteString, "https://api.openai.com/v1/images/variations")
            XCTAssertEqual(method, "POST")
            
            if let body = body, let requestString = String(data: body, encoding: .utf8) {
                XCTAssertTrue(requestString.contains("\"image\":"))
            } else {
                XCTFail("Invalid request body")
            }
            
            return (
                TestFixtures.imageVariationSuccessData,
                TestFixtures.mockHTTPResponse(url: url, statusCode: 200),
                nil
            )
        }
        
        client.createImageVariation(
            image: TestFixtures.sampleImageData
        ) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.data.count, 1)
                XCTAssertEqual(response.data[0].url, "https://example.com/variation-image.png")
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    #if os(macOS) && swift(>=5.5)
    // MARK: - Async/Await Tests
    
    @available(macOS 12.0, *)
    func testCreateImageAsync() async {
        mockNetworkSession.requestHandler = { url, method, headers, body in
            return (
                TestFixtures.createImageSuccessData,
                TestFixtures.mockHTTPResponse(url: url, statusCode: 200),
                nil
            )
        }
        
        do {
            let response = try await client.createImage(prompt: "A cute baby sea otter")
            XCTAssertEqual(response.data.count, 1)
            XCTAssertEqual(response.data[0].url, "https://example.com/image.png")
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }
    }
    #endif
}