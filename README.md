# OpenAIImagesKit

A Swift package for interacting with OpenAI's Images API.

## Features

- Create images using DALL-E models
- Edit existing images
- Create variations of images
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

```swift
import OpenAIImagesKit

// Initialize the client
let client = OpenAIImagesClient(apiKey: "your-api-key")

// Create an image
client.createImage(prompt: "A cute baby sea otter") { result in
    switch result {
    case .success(let images):
        print("Image URL: \(images.data[0].url)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

## License

MIT