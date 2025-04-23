import Foundation

// Export all public types
// This file serves as a convenient place to include documentation and examples

/// OpenAIImagesKit provides a Swift interface to the OpenAI Images API
///
/// Example usage with async/await:
///
/// ```swift
/// import OpenAIImagesKit
///
/// // Initialize with your API key
/// let client = OpenAIImagesClient(apiKey: "your-api-key")
///
/// // Create an image using async/await
/// do {
///     let response = try await client.createImage(prompt: "A cute baby sea otter")
///     if let imageUrl = response.data.first?.url {
///         print("Image created: \(imageUrl)")
///     }
/// } catch {
///     print("Error: \(error.localizedDescription)")
/// }
/// ```
///
/// Example with completion handlers:
///
/// ```swift
/// // Initialize with your API key
/// let client = OpenAIImagesClient(apiKey: "your-api-key")
///
/// // Create an image with completion handler
/// client.createImage(prompt: "A cute baby sea otter") { result in
///     switch result {
///     case .success(let response):
///         if let imageUrl = response.data.first?.url {
///             print("Image created: \(imageUrl)")
///         }
///     case .failure(let error):
///         print("Error: \(error.localizedDescription)")
///     }
/// }
/// ```
///
/// For more advanced usage and options, see the README.md and API documentation.
public struct OpenAIImagesKit {
    // Package version
    public static let version = "1.0.0"
}