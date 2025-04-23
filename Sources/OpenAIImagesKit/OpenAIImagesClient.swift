import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class OpenAIImagesClient {
    private let apiKey: String
    private let networkSession: NetworkSessionProtocol
    private let baseURL = "https://api.openai.com/v1"
    
    public init(apiKey: String, networkSession: NetworkSessionProtocol? = nil) {
        self.apiKey = apiKey
        self.networkSession = networkSession ?? NetworkSession()
    }
    
    // MARK: - Create Image
    
    public func createImage(request: CreateImageRequest, completion: @escaping (Result<ImagesResponse, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            completion(.failure(OpenAIImagesError.invalidAPIKey))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/images/generations") else {
            completion(.failure(OpenAIImagesError.invalidRequest))
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let requestData = try encoder.encode(request)
            
            networkSession.performRequest(
                url: url,
                method: "POST",
                headers: [
                    "Content-Type": "application/json",
                    "Authorization": "Bearer \(apiKey)"
                ],
                body: requestData,
                completion: completion
            )
        } catch {
            completion(.failure(OpenAIImagesError.failedToEncodeRequest))
        }
    }
    
    public func createImage(
        prompt: String,
        model: ImageModel = .dallE3,
        n: Int? = 1,
        quality: ImageQuality? = .standard,
        responseFormat: ResponseFormat? = .url,
        size: ImageSize = .size1024x1024,
        style: ImageStyle? = .vivid,
        user: String? = nil,
        completion: @escaping (Result<ImagesResponse, Error>) -> Void
    ) {
        let request = CreateImageRequest(
            model: model,
            prompt: prompt,
            n: n,
            quality: quality,
            responseFormat: responseFormat,
            size: size,
            style: style,
            user: user
        )
        
        createImage(request: request, completion: completion)
    }
    
    // MARK: - Edit Image
    
    public func editImage(request: CreateImageEditRequest, completion: @escaping (Result<ImagesResponse, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            completion(.failure(OpenAIImagesError.invalidAPIKey))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/images/edits") else {
            completion(.failure(OpenAIImagesError.invalidRequest))
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let requestData = try encoder.encode(request)
            
            networkSession.performRequest(
                url: url,
                method: "POST",
                headers: [
                    "Content-Type": "application/json",
                    "Authorization": "Bearer \(apiKey)"
                ],
                body: requestData,
                completion: completion
            )
        } catch {
            completion(.failure(OpenAIImagesError.failedToEncodeRequest))
        }
    }
    
    public func editImage(
        image: Data,
        mask: Data? = nil,
        prompt: String,
        model: ImageModel = .dallE2,
        n: Int? = 1,
        size: ImageSize? = .size1024x1024,
        responseFormat: ResponseFormat? = .url,
        user: String? = nil,
        completion: @escaping (Result<ImagesResponse, Error>) -> Void
    ) {
        // Convert image and mask to base64 strings
        guard let base64Image = image.base64EncodedString() as String? else {
            completion(.failure(OpenAIImagesError.failedToEncodeImage))
            return
        }
        
        let base64Mask: String?
        if let maskData = mask {
            guard let encodedMask = maskData.base64EncodedString() as String? else {
                completion(.failure(OpenAIImagesError.failedToEncodeImage))
                return
            }
            base64Mask = encodedMask
        } else {
            base64Mask = nil
        }
        
        let request = CreateImageEditRequest(
            image: base64Image,
            mask: base64Mask,
            model: model,
            prompt: prompt,
            n: n,
            size: size,
            responseFormat: responseFormat,
            user: user
        )
        
        editImage(request: request, completion: completion)
    }
    
    // MARK: - Create Image Variation
    
    public func createImageVariation(request: CreateImageVariationRequest, completion: @escaping (Result<ImagesResponse, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            completion(.failure(OpenAIImagesError.invalidAPIKey))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/images/variations") else {
            completion(.failure(OpenAIImagesError.invalidRequest))
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let requestData = try encoder.encode(request)
            
            networkSession.performRequest(
                url: url,
                method: "POST",
                headers: [
                    "Content-Type": "application/json",
                    "Authorization": "Bearer \(apiKey)"
                ],
                body: requestData,
                completion: completion
            )
        } catch {
            completion(.failure(OpenAIImagesError.failedToEncodeRequest))
        }
    }
    
    public func createImageVariation(
        image: Data,
        model: ImageModel = .dallE2,
        n: Int? = 1,
        responseFormat: ResponseFormat? = .url,
        size: ImageSize? = .size1024x1024,
        user: String? = nil,
        completion: @escaping (Result<ImagesResponse, Error>) -> Void
    ) {
        // Convert image to base64 string
        guard let base64Image = image.base64EncodedString() as String? else {
            completion(.failure(OpenAIImagesError.failedToEncodeImage))
            return
        }
        
        let request = CreateImageVariationRequest(
            image: base64Image,
            model: model,
            n: n,
            responseFormat: responseFormat,
            size: size,
            user: user
        )
        
        createImageVariation(request: request, completion: completion)
    }
}

// MARK: - Async/Await Support

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension OpenAIImagesClient {
    // MARK: - Create Image
    
    public func createImage(request: CreateImageRequest) async throws -> ImagesResponse {
        return try await withCheckedThrowingContinuation { continuation in
            createImage(request: request) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    public func createImage(
        prompt: String,
        model: ImageModel = .dallE3,
        n: Int? = 1,
        quality: ImageQuality? = .standard,
        responseFormat: ResponseFormat? = .url,
        size: ImageSize = .size1024x1024,
        style: ImageStyle? = .vivid,
        user: String? = nil
    ) async throws -> ImagesResponse {
        return try await withCheckedThrowingContinuation { continuation in
            createImage(
                prompt: prompt,
                model: model,
                n: n,
                quality: quality,
                responseFormat: responseFormat,
                size: size,
                style: style,
                user: user
            ) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    // MARK: - Edit Image
    
    public func editImage(request: CreateImageEditRequest) async throws -> ImagesResponse {
        return try await withCheckedThrowingContinuation { continuation in
            editImage(request: request) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    public func editImage(
        image: Data,
        mask: Data? = nil,
        prompt: String,
        model: ImageModel = .dallE2,
        n: Int? = 1,
        size: ImageSize? = .size1024x1024,
        responseFormat: ResponseFormat? = .url,
        user: String? = nil
    ) async throws -> ImagesResponse {
        return try await withCheckedThrowingContinuation { continuation in
            editImage(
                image: image,
                mask: mask,
                prompt: prompt,
                model: model,
                n: n,
                size: size,
                responseFormat: responseFormat,
                user: user
            ) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    // MARK: - Create Image Variation
    
    public func createImageVariation(request: CreateImageVariationRequest) async throws -> ImagesResponse {
        return try await withCheckedThrowingContinuation { continuation in
            createImageVariation(request: request) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    public func createImageVariation(
        image: Data,
        model: ImageModel = .dallE2,
        n: Int? = 1,
        responseFormat: ResponseFormat? = .url,
        size: ImageSize? = .size1024x1024,
        user: String? = nil
    ) async throws -> ImagesResponse {
        return try await withCheckedThrowingContinuation { continuation in
            createImageVariation(
                image: image,
                model: model,
                n: n,
                responseFormat: responseFormat,
                size: size,
                user: user
            ) { result in
                continuation.resume(with: result)
            }
        }
    }
}