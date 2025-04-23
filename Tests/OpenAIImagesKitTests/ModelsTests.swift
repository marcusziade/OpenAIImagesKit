import XCTest
@testable import OpenAIImagesKit

final class ModelsTests: XCTestCase {
    
    func testCreateImageRequestEncoding() throws {
        let request = CreateImageRequest(
            model: .gptImage1,
            prompt: "A cute baby sea otter",
            n: 1,
            quality: .standard,
            responseFormat: .url,
            size: .size1024x1024,
            style: .vivid,
            user: "test-user"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["model"] as? String, "gpt-image-1")
        XCTAssertEqual(json["prompt"] as? String, "A cute baby sea otter")
        XCTAssertEqual(json["n"] as? Int, 1)
        XCTAssertEqual(json["quality"] as? String, "standard")
        XCTAssertEqual(json["response_format"] as? String, "url")
        XCTAssertEqual(json["size"] as? String, "1024x1024")
        XCTAssertEqual(json["style"] as? String, "vivid")
        XCTAssertEqual(json["user"] as? String, "test-user")
    }
    
    func testCreateImageEditRequestEncoding() throws {
        let base64Image = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="
        
        let request = CreateImageEditRequest(
            image: base64Image,
            mask: base64Image,
            model: .dallE2,
            prompt: "Add a hat",
            n: 1,
            size: .size1024x1024,
            responseFormat: .url,
            user: "test-user"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["image"] as? String, base64Image)
        XCTAssertEqual(json["mask"] as? String, base64Image)
        XCTAssertEqual(json["model"] as? String, "dall-e-2")
        XCTAssertEqual(json["prompt"] as? String, "Add a hat")
        XCTAssertEqual(json["n"] as? Int, 1)
        XCTAssertEqual(json["size"] as? String, "1024x1024")
        XCTAssertEqual(json["response_format"] as? String, "url")
        XCTAssertEqual(json["user"] as? String, "test-user")
    }
    
    func testCreateImageVariationRequestEncoding() throws {
        let base64Image = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="
        
        let request = CreateImageVariationRequest(
            image: base64Image,
            model: .dallE2,
            n: 2,
            responseFormat: .b64Json,
            size: .size512x512,
            user: "test-user"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["image"] as? String, base64Image)
        XCTAssertEqual(json["model"] as? String, "dall-e-2")
        XCTAssertEqual(json["n"] as? Int, 2)
        XCTAssertEqual(json["response_format"] as? String, "b64_json")
        XCTAssertEqual(json["size"] as? String, "512x512")
        XCTAssertEqual(json["user"] as? String, "test-user")
    }
    
    func testImagesResponseDecoding() throws {
        let json = """
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
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(ImagesResponse.self, from: json)
        
        XCTAssertEqual(response.created, 1677254147)
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.data[0].url, "https://example.com/image.png")
        XCTAssertEqual(response.data[0].revisedPrompt, "A cute baby sea otter floating on its back in blue water.")
        XCTAssertNil(response.data[0].b64Json)
    }
    
    func testImagesResponseWithB64JsonDecoding() throws {
        let json = """
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
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(ImagesResponse.self, from: json)
        
        XCTAssertEqual(response.created, 1677254147)
        XCTAssertEqual(response.data.count, 1)
        XCTAssertNil(response.data[0].url)
        XCTAssertEqual(response.data[0].b64Json, "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")
        XCTAssertEqual(response.data[0].revisedPrompt, "A cute baby sea otter floating on its back in blue water.")
    }
}