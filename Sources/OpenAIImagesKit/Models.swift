import Foundation

public enum ImageModel: String, Codable {
    case gptImage1 = "gpt-image-1"
    case dallE2 = "dall-e-2"
    case dallE3 = "dall-e-3"
}

public enum ImageSize: String, Codable {
    // Auto size (gpt-image-1)
    case auto = "auto"
    
    // DALL-E 3 sizes
    case size1024x1024 = "1024x1024"
    case size1792x1024 = "1792x1024"
    case size1024x1792 = "1024x1792"
    
    // DALL-E 2 sizes
    case size256x256 = "256x256"
    case size512x512 = "512x512"
    
    // gpt-image-1 adds landscape & portrait at 1536 resolution
    case size1536x1024 = "1536x1024" // landscape
    case size1024x1536 = "1024x1536" // portrait
}

public enum ImageQuality: String, Codable {
    // Standard quality (DALL-E 2)
    case standard
    
    // HD quality (DALL-E 3)
    case hd
    
    // gpt-image-1 qualities
    case high
    case medium
    case low
    
    // Auto quality
    case auto = "auto"
}

public enum ImageStyle: String, Codable {
    case vivid
    case natural
}

public enum ResponseFormat: String, Codable {
    case url
    case b64Json = "b64_json"
}

public enum BackgroundType: String, Codable {
    case transparent
    case opaque
    case auto = "auto"
}

public enum OutputFormat: String, Codable {
    case png
    case jpeg
    case webp
}

public enum ModerationLevel: String, Codable {
    case low
    case auto = "auto"
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

public struct TokenUsageDetails: Codable {
    public let textTokens: Int
    public let imageTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case textTokens = "text_tokens"
        case imageTokens = "image_tokens"
    }
}

public struct TokenUsage: Codable {
    public let totalTokens: Int
    public let inputTokens: Int
    public let outputTokens: Int
    public let inputTokensDetails: TokenUsageDetails?
    
    enum CodingKeys: String, CodingKey {
        case totalTokens = "total_tokens"
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case inputTokensDetails = "input_tokens_details"
    }
}

public struct ImagesResponse: Codable {
    public let created: Int
    public let data: [ImageData]
    public let usage: TokenUsage?
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
    
    // gpt-image-1 specific parameters
    public let background: BackgroundType?
    public let outputFormat: OutputFormat?
    public let outputCompression: Int?
    public let moderation: ModerationLevel?
    
    enum CodingKeys: String, CodingKey {
        case model, prompt, n, quality, size, style, user, background, moderation
        case responseFormat = "response_format"
        case outputFormat = "output_format"
        case outputCompression = "output_compression"
    }
    
    // Custom encoding to only include style for DALL-E 3
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(model, forKey: .model)
        try container.encode(prompt, forKey: .prompt)
        
        if let n = n {
            try container.encode(n, forKey: .n)
        }
        
        // Quality parameter is not supported for DALL-E 2
        if model != .dallE2, let quality = quality {
            try container.encode(quality, forKey: .quality)
        }
        
        // response_format is only for DALL-E models, not gpt-image-1
        if model != .gptImage1, let responseFormat = responseFormat {
            try container.encode(responseFormat, forKey: .responseFormat)
        }
        
        try container.encode(size, forKey: .size)
        
        // Only include style for DALL-E 3
        if model == .dallE3, let style = style {
            try container.encode(style, forKey: .style)
        }
        
        if let user = user {
            try container.encode(user, forKey: .user)
        }
        
        // gpt-image-1 specific parameters
        if model == .gptImage1 {
            if let background = background {
                try container.encode(background, forKey: .background)
            }
            
            if let outputFormat = outputFormat {
                try container.encode(outputFormat, forKey: .outputFormat)
            }
            
            if let outputCompression = outputCompression {
                try container.encode(outputCompression, forKey: .outputCompression)
            }
            
            if let moderation = moderation {
                try container.encode(moderation, forKey: .moderation)
            }
        }
    }
    
    public init(
        model: ImageModel = .gptImage1,
        prompt: String,
        n: Int? = 1,
        quality: ImageQuality? = .auto,
        responseFormat: ResponseFormat? = .url,
        size: ImageSize = .auto,
        style: ImageStyle? = .vivid,
        user: String? = nil,
        background: BackgroundType? = nil,
        outputFormat: OutputFormat? = nil,
        outputCompression: Int? = nil,
        moderation: ModerationLevel? = nil
    ) {
        self.model = model
        self.prompt = prompt
        self.n = n
        self.quality = quality
        self.responseFormat = responseFormat
        self.size = size
        self.style = style
        self.user = user
        self.background = background
        self.outputFormat = outputFormat
        self.outputCompression = outputCompression
        self.moderation = moderation
        
        // Validate outputCompression range if provided
        if let compression = outputCompression {
            assert(compression >= 0 && compression <= 100, "Output compression must be between 0 and 100")
        }
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