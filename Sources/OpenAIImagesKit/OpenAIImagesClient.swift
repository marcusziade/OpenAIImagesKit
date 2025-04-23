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
public extension OpenAIImagesClient {
    // MARK: - Create Image

    /// Creates an image using the specified `CreateImageRequest`.
    ///
    /// - Parameter request: The parameters for image creation.
    /// - Returns: An `ImagesResponse` containing the generated images.
    /// - Throws: An `OpenAIImagesError` if the request fails.
    func createImage(request: CreateImageRequest) async throws -> ImagesResponse {
        guard !apiKey.isEmpty else {
            throw OpenAIImagesError.invalidAPIKey
        }
        guard let url = URL(string: "\(baseURL)/images/generations") else {
            throw OpenAIImagesError.invalidRequest
        }
        let data: Data
        do {
            data = try JSONEncoder().encode(request)
        } catch {
            throw OpenAIImagesError.failedToEncodeRequest
        }
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        return try await networkSession.performRequest(url: url, method: "POST", headers: headers, body: data)
    }

    /// Creates an image with the provided parameters.
    ///
    /// - Parameters:
    ///   - prompt: The prompt to generate the image.
    ///   - model: The image generation model to use.
    ///   - n: The number of images to generate.
    ///   - quality: The image quality setting.
    ///   - responseFormat: The format of the image response.
    ///   - size: The size of the generated image.
    ///   - style: The style to apply to the image.
    ///   - user: An optional end-user identifier.
    /// - Returns: An `ImagesResponse` containing the generated images.
    /// - Throws: An `OpenAIImagesError` if the request fails.
    func createImage(
        prompt: String,
        model: ImageModel = .dallE3,
        n: Int? = 1,
        quality: ImageQuality? = .standard,
        responseFormat: ResponseFormat? = .url,
        size: ImageSize = .size1024x1024,
        style: ImageStyle? = .vivid,
        user: String? = nil
    ) async throws -> ImagesResponse {
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
        return try await createImage(request: request)
    }

    // MARK: - Edit Image

    /// Edits an existing image using the specified `CreateImageEditRequest`.
    ///
    /// - Parameter request: The parameters for image editing.
    /// - Returns: An `ImagesResponse` containing the edited images.
    /// - Throws: An `OpenAIImagesError` if the request fails.
    func editImage(request: CreateImageEditRequest) async throws -> ImagesResponse {
        guard !apiKey.isEmpty else {
            throw OpenAIImagesError.invalidAPIKey
        }
        guard let url = URL(string: "\(baseURL)/images/edits") else {
            throw OpenAIImagesError.invalidRequest
        }
        let data: Data
        do {
            data = try JSONEncoder().encode(request)
        } catch {
            throw OpenAIImagesError.failedToEncodeRequest
        }
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        return try await networkSession.performRequest(url: url, method: "POST", headers: headers, body: data)
    }

    /// Edits an image with the provided parameters.
    ///
    /// - Parameters:
    ///   - image: The image data to edit.
    ///   - mask: Optional mask data to guide the edit.
    ///   - prompt: The prompt describing the edit.
    ///   - model: The image editing model to use.
    ///   - n: The number of images to generate.
    ///   - size: The size of the edited image.
    ///   - responseFormat: The format of the image response.
    ///   - user: An optional end-user identifier.
    /// - Returns: An `ImagesResponse` containing the edited images.
    /// - Throws: An `OpenAIImagesError` if the request fails.
    func editImage(
        image: Data,
        mask: Data? = nil,
        prompt: String,
        model: ImageModel = .dallE2,
        n: Int? = 1,
        size: ImageSize? = .size1024x1024,
        responseFormat: ResponseFormat? = .url,
        user: String? = nil
    ) async throws -> ImagesResponse {
        let base64Image = image.base64EncodedString()
        let base64Mask = mask?.base64EncodedString()
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
        return try await editImage(request: request)
    }

    // MARK: - Create Image Variation

    /// Creates a variation of an image using the specified `CreateImageVariationRequest`.
    ///
    /// - Parameter request: The parameters for creating an image variation.
    /// - Returns: An `ImagesResponse` containing the image variations.
    /// - Throws: An `OpenAIImagesError` if the request fails.
    func createImageVariation(request: CreateImageVariationRequest) async throws -> ImagesResponse {
        guard !apiKey.isEmpty else {
            throw OpenAIImagesError.invalidAPIKey
        }
        guard let url = URL(string: "\(baseURL)/images/variations") else {
            throw OpenAIImagesError.invalidRequest
        }
        let data: Data
        do {
            data = try JSONEncoder().encode(request)
        } catch {
            throw OpenAIImagesError.failedToEncodeRequest
        }
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        return try await networkSession.performRequest(url: url, method: "POST", headers: headers, body: data)
    }

    /// Creates a variation of an image with the provided parameters.
    ///
    /// - Parameters:
    ///   - image: The image data to vary.
    ///   - model: The image variation model to use.
    ///   - n: The number of image variations to generate.
    ///   - responseFormat: The format of the image response.
    ///   - size: The size of the image variation.
    ///   - user: An optional end-user identifier.
    /// - Returns: An `ImagesResponse` containing the image variations.
    /// - Throws: An `OpenAIImagesError` if the request fails.
    func createImageVariation(
        image: Data,
        model: ImageModel = .dallE2,
        n: Int? = 1,
        responseFormat: ResponseFormat? = .url,
        size: ImageSize? = .size1024x1024,
        user: String? = nil
    ) async throws -> ImagesResponse {
        let base64Image = image.base64EncodedString()
        let request = CreateImageVariationRequest(
            image: base64Image,
            model: model,
            n: n,
            responseFormat: responseFormat,
            size: size,
            user: user
        )
        return try await createImageVariation(request: request)
    }
}