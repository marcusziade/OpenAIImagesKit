import Foundation

public enum ImageModel: String, Codable {
    case gptImage1 = "gpt-image-1"
    case dallE2 = "dall-e-2"
    case dallE3 = "dall-e-3"
}

public enum ImageSize: String, Codable {
    // DALL-E 3 sizes
    case size1024x1024 = "1024x1024"
    case size1792x1024 = "1792x1024"
    case size1024x1792 = "1024x1792"
    
    // DALL-E 2 sizes
    case size256x256 = "256x256"
    case size512x512 = "512x512"
}

public enum ImageQuality: String, Codable {
    case standard
    case hd
}

public enum ImageStyle: String, Codable {
    case vivid
    case natural
}

public enum ResponseFormat: String, Codable {
    case url
    case b64Json = "b64_json"
}

public struct ImageData: Codable {
    public let url: String?
    public let b64Json: String?
    public let revisedPrompt: String?
    
    enum CodingKeys: String, CodingKey {
        case url
        case b64Json = "b64_json"
        case revisedPrompt = "revised_prompt"
    }
}

public struct ImagesResponse: Codable {
    public let created: Int
    public let data: [ImageData]
}

// Request models
public struct CreateImageRequest: Codable {
    public let model: ImageModel
    public let prompt: String
    public let n: Int?
    public let quality: ImageQuality?
    public let responseFormat: ResponseFormat?
    public let size: ImageSize
    public let style: ImageStyle?
    public let user: String?
    
    enum CodingKeys: String, CodingKey {
        case model, prompt, n, quality, size, style, user
        case responseFormat = "response_format"
    }
    
    public init(
        model: ImageModel = .gptImage1,
        prompt: String,
        n: Int? = 1,
        quality: ImageQuality? = .standard,
        responseFormat: ResponseFormat? = .url,
        size: ImageSize = .size1024x1024,
        style: ImageStyle? = .vivid,
        user: String? = nil
    ) {
        self.model = model
        self.prompt = prompt
        self.n = n
        self.quality = quality
        self.responseFormat = responseFormat
        self.size = size
        self.style = style
        self.user = user
    }
}

public struct CreateImageEditRequest: Codable {
    public let image: String  // Base64 encoded image
    public let mask: String?  // Base64 encoded mask image
    public let model: ImageModel?
    public let prompt: String
    public let n: Int?
    public let size: ImageSize?
    public let responseFormat: ResponseFormat?
    public let user: String?
    
    enum CodingKeys: String, CodingKey {
        case image, mask, model, prompt, n, size, user
        case responseFormat = "response_format"
    }
    
    public init(
        image: String,
        mask: String? = nil,
        model: ImageModel? = .dallE2,
        prompt: String,
        n: Int? = 1,
        size: ImageSize? = .size1024x1024,
        responseFormat: ResponseFormat? = .url,
        user: String? = nil
    ) {
        self.image = image
        self.mask = mask
        self.model = model
        self.prompt = prompt
        self.n = n
        self.size = size
        self.responseFormat = responseFormat
        self.user = user
    }
}

public struct CreateImageVariationRequest: Codable {
    public let image: String  // Base64 encoded image
    public let model: ImageModel?
    public let n: Int?
    public let responseFormat: ResponseFormat?
    public let size: ImageSize?
    public let user: String?
    
    enum CodingKeys: String, CodingKey {
        case image, model, n, size, user
        case responseFormat = "response_format"
    }
    
    public init(
        image: String,
        model: ImageModel? = .dallE2,
        n: Int? = 1,
        responseFormat: ResponseFormat? = .url,
        size: ImageSize? = .size1024x1024,
        user: String? = nil
    ) {
        self.image = image
        self.model = model
        self.n = n
        self.responseFormat = responseFormat
        self.size = size
        self.user = user
    }
}