import Foundation

/// Example usages of the OpenAIImagesKit
public enum Examples {
    
    /// Example of using the client to create an image
    public static func createImageExample(apiKey: String, completion: @escaping (Result<URL?, Error>) -> Void) {
        let client = OpenAIImagesClient(apiKey: apiKey)
        
        // Create a simple image
        client.createImage(
            prompt: "A cute baby sea otter floating on its back in blue water",
            model: .dallE3,
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
    
    /// Example of using the client to edit an image
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
    
    /// Example of using the client to create an image variation
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
    
    /// Example of using the client with async/await syntax
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    public static func asyncAwaitExample(apiKey: String) async throws -> URL? {
        let client = OpenAIImagesClient(apiKey: apiKey)
        
        // Create an image with async/await
        let response = try await client.createImage(
            prompt: "A beautiful sunset over the ocean with palm trees in the foreground",
            model: .dallE3,
            quality: .hd,
            size: .size1792x1024
        )
        
        if let url = response.data.first?.url {
            return URL(string: url)
        }
        
        return nil
    }
}