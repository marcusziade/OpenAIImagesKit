# OpenAIImagesKit

A Swift package for interacting with OpenAI's Images API.

## Features

- Create images using OpenAI image models (gpt-image-1, DALL-E 3, DALL-E 2)
- Edit existing images
- Create variations of images
- Modern Swift async/await support
- Cross-platform: works on macOS and Linux

## Requirements

- Swift 5.7+
- macOS 12.0+ or Linux

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/OpenAIImagesKit.git", from: "1.0.0")
]
```

## Usage

### Async/Await Usage (Recommended)

```swift
import OpenAIImagesKit

// Initialize the client
let client = OpenAIImagesClient(apiKey: "your-api-key")

// Create an image with async/await
do {
    // Uses gpt-image-1 model by default
    let response = try await client.createImage(prompt: "A cute baby sea otter")
    if let url = response.data.first?.url {
        print("Image URL: \(url)")
    }
} catch {
    print("Error: \(error)")
}

// Create an image with DALL-E 3
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

A simple command-line tool is included to demonstrate the library:

```bash
# Set your API key in the environment
export OPENAI_API_KEY=your-api-key-here

# Run the CLI tool
swift run OpenAIImagesCLI create "A cute baby sea otter"
```

## License

MIT