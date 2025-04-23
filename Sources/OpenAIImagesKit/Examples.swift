import Foundation

/// Example usages of the OpenAIImagesKit
public enum Examples {
    
    // MARK: - Async/Await Examples
    
    /// Example of using the client to create an image with async/await
    public func createImageAsyncExample(apiKey: String) async throws -> URL? {
        let client = OpenAIImagesClient(apiKey: apiKey)
        
        // Create an image with async/await and gpt-image-1 model (default)
        let response = try await client.createImage(
            prompt: "A beautiful sunset over the ocean with palm trees in the foreground",
            quality: .hd,
            size: .size1024x1024
        )
        
        if let url = response.data.first?.url {
            return URL(string: url)
        }
        
        return nil
    }
    
    /// Example of using the client to edit an image with async/await
    public func editImageAsyncExample(apiKey: String, imageData: Data) async throws -> URL? {
        let client = OpenAIImagesClient(apiKey: apiKey)
        
        // Edit an image with async/await
        let response = try await client.editImage(
            image: imageData,
            prompt: "Add a tiny hat"
        )
        
        if let url = response.data.first?.url {
            return URL(string: url)
        }
        
        return nil
    }
    
    /// Example of using the client to create an image variation with async/await
    public func createVariationAsyncExample(apiKey: String, imageData: Data) async throws -> URL? {
        let client = OpenAIImagesClient(apiKey: apiKey)
        
        // Create a variation with async/await
        let response = try await client.createImageVariation(
            image: imageData,
            n: 2  // Generate 2 variations
        )
        
        if let url = response.data.first?.url {
            return URL(string: url)
        }
        
        return nil
    }
    
    // MARK: - Callback-based Examples
    
    /// Example of using the client to create an image with completion handlers
    public static func createImageExample(apiKey: String, completion: @escaping (Result<URL?, Error>) -> Void) {
        let client = OpenAIImagesClient(apiKey: apiKey)
        
        // Create a simple image
        client.createImage(
            prompt: "A cute baby sea otter floating on its back in blue water",
            model: .gptImage1,
            size: .size1024x1024,
            style: .vivid
        ) { result in
            switch result {
            case .success(let response):
                if let url = response.data.first?.url {
                    completion(.success(URL(string: url)))
                } else {
                    completion(.success(nil))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Example of using the client to edit an image with completion handlers
    public static func editImageExample(apiKey: String, imageData: Data, completion: @escaping (Result<URL?, Error>) -> Void) {
        let client = OpenAIImagesClient(apiKey: apiKey)
        
        // Edit an image
        client.editImage(
            image: imageData,
            prompt: "Add a tiny hat"
        ) { result in
            switch result {
            case .success(let response):
                if let url = response.data.first?.url {
                    completion(.success(URL(string: url)))
                } else {
                    completion(.success(nil))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Example of using the client to create an image variation with completion handlers
    public static func createVariationExample(apiKey: String, imageData: Data, completion: @escaping (Result<URL?, Error>) -> Void) {
        let client = OpenAIImagesClient(apiKey: apiKey)
        
        // Create a variation
        client.createImageVariation(
            image: imageData,
            n: 2  // Generate 2 variations
        ) { result in
            switch result {
            case .success(let response):
                if let url = response.data.first?.url {
                    completion(.success(URL(string: url)))
                } else {
                    completion(.success(nil))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}