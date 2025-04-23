# OpenAIImagesKit

A Swift package for interacting with OpenAI's Images API.

## Features

- Create images using OpenAI image models (gpt-image-1, DALL-E 3, DALL-E 2)
- Edit existing images
- Create variations of images
- Full support for gpt-image-1 specific parameters (transparency, output formats, compression, moderation)
- Modern Swift async/await support
- Cross-platform: works on macOS and Linux
- Command-line tool with rich parameter options

## Requirements

- Swift 5.7+
- macOS 12.0+ or Linux

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/marcusziade/OpenAIImagesKit.git", from: "1.0.0")
]
```

## Usage

### Async/Await Usage (Recommended)

```swift
import OpenAIImagesKit

// Initialize the client
let client = OpenAIImagesClient(apiKey: "your-api-key")

// Create an image with async/await (basic usage)
do {
    // Uses gpt-image-1 model by default
    let response = try await client.createImage(prompt: "A cute baby sea otter")
    if let url = response.data.first?.url {
        print("Image URL: \(url)")
    }
} catch {
    print("Error: \(error)")
}

// Create an image with DALL-E 3 (with specific parameters)
do {
    let response = try await client.createImage(
        prompt: "A beautiful sunset over the ocean",
        model: .dallE3,
        quality: .hd,
        size: .size1024x1024
    )
    if let url = response.data.first?.url {
        print("Image URL: \(url)")
    }
} catch {
    print("Error: \(error)")
}

// Create an image with gpt-image-1 (with specific parameters)
do {
    let response = try await client.createImage(
        prompt: "A red apple on a plain background",
        model: .gptImage1,
        quality: .high,
        size: .size1536x1024,
        background: .transparent,
        outputFormat: .webp,
        outputCompression: 90,
        moderation: .low
    )
    
    // For gpt-image-1, the image data is returned as base64
    if let b64Data = response.data.first?.b64Json,
       let imageData = Data(base64Encoded: b64Data) {
        // Save or process the image data
        print("Got image data: \(imageData.count) bytes")
    }
    
    // Token usage is available for gpt-image-1
    if let usage = response.usage {
        print("Total tokens: \(usage.totalTokens)")
        print("Input tokens: \(usage.inputTokens)")
        print("Output tokens: \(usage.outputTokens)")
    }
} catch {
    print("Error: \(error)")
}
```

### Completion Handler Usage (Legacy)

```swift
// Initialize the client
let client = OpenAIImagesClient(apiKey: "your-api-key")

// Create an image with completion handler
client.createImage(prompt: "A cute baby sea otter") { result in
    switch result {
    case .success(let images):
        print("Image URL: \(images.data[0].url)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

## Models

OpenAIImagesKit supports all OpenAI image generation models:

- `gptImage1` (default): OpenAI's newest image generation model
- `dallE3`: DALL-E 3 model
- `dallE2`: DALL-E 2 model

## Command-Line Tool

A feature-rich command-line tool is included to demonstrate the library:

```bash
# Set your API key in the environment
export OPENAI_API_KEY=your-api-key-here

# Basic usage
swift run OpenAIImagesCLI create "A cute baby sea otter"

# Advanced usage with gpt-image-1 specific parameters
swift run OpenAIImagesCLI create --model gpt-image-1 --size 1536x1024 --quality high "Mountain landscape at sunset"

# Using transparency, output format and compression
swift run OpenAIImagesCLI create --background transparent --output-format webp --compression 90 "A red apple on white background"
```

The CLI tool supports all parameters available in the API:

```
Options:
  --model <model>           Model to use: gpt-image-1 (default), dall-e-2, dall-e-3
  --n <count>               Number of images to generate (1-10)
  --size <size>             Image size: auto (default), 1024x1024, 1536x1024, 1024x1536, etc.
  --quality <quality>       Image quality: auto (default), standard, hd, high, medium, low
  --style <style>           Image style: vivid (default), natural (DALL-E 3 only)
  --background <type>       Background type: auto (default), transparent, opaque (gpt-image-1 only)
  --output-format <format>  Output format: png (default), jpeg, webp (gpt-image-1 only)
  --compression <level>     Compression level 0-100 for webp/jpeg (gpt-image-1 only)
  --moderation <level>      Moderation level: auto (default), low (gpt-image-1 only)
```

## License

MIT
