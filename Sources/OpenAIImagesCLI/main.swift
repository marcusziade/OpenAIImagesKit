import Foundation
import OpenAIImagesKit

// Define a more robust CLI tool with argument parsing

@main
struct OpenAIImagesCLI {
    static func main() async {
        // Get API key from environment
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        
        if apiKey.isEmpty {
            print("Error: Please set the OPENAI_API_KEY environment variable")
            exit(1)
        }
        
        // Parse command line arguments
        let args = CommandLine.arguments
        
        if args.count < 2 {
            printUsage()
            exit(1)
        }
        
        let command = args[1]
        let client = OpenAIImagesClient(apiKey: apiKey)
        
        // Run the requested command
        switch command {
        case "create":
            await handleCreateImage(client: client, args: Array(args.dropFirst(2)))
            
        case "help":
            printUsage()
            
        default:
            print("Unknown command: \(command)")
            printUsage()
            exit(1)
        }
    }
    
    // Handle the create image command with options
    static func handleCreateImage(client: OpenAIImagesClient, args: [String]) async {
        var prompt = ""
        var model: ImageModel = .gptImage1
        var n: Int = 1
        var quality: ImageQuality = .auto
        var size: ImageSize = .auto
        
        // Default quality based on model
        var qualitySpecified = false
        var style: ImageStyle? = .vivid
        var background: BackgroundType? = nil
        var outputFormat: OutputFormat? = nil
        var outputCompression: Int? = nil
        var moderation: ModerationLevel? = nil
        
        // Parse arguments
        var i = 0
        while i < args.count {
            let arg = args[i]
            
            if arg.starts(with: "--") {
                // Handle options
                let option = arg.dropFirst(2) // Remove -- prefix
                
                switch option {
                case "model":
                    if i + 1 < args.count {
                        switch args[i + 1] {
                        case "gpt-image-1":
                            model = .gptImage1
                        case "dall-e-2":
                            model = .dallE2
                        case "dall-e-3":
                            model = .dallE3
                        default:
                            print("Invalid model: \(args[i + 1]). Using default: gpt-image-1")
                        }
                        i += 1
                    }
                    
                case "n":
                    if i + 1 < args.count, let count = Int(args[i + 1]), count > 0 && count <= 10 {
                        n = count
                        i += 1
                    } else {
                        print("Invalid count. Using default: 1")
                    }
                    
                case "size":
                    if i + 1 < args.count {
                        switch args[i + 1] {
                        case "auto":
                            size = .auto
                        case "1024x1024":
                            size = .size1024x1024
                        case "1536x1024":
                            size = .size1536x1024
                        case "1024x1536":
                            size = .size1024x1536
                        case "1792x1024":
                            size = .size1792x1024
                        case "1024x1792":
                            size = .size1024x1792
                        case "256x256":
                            size = .size256x256
                        case "512x512":
                            size = .size512x512
                        default:
                            print("Invalid size: \(args[i + 1]). Using default: auto")
                        }
                        i += 1
                    }
                    
                case "quality":
                    if i + 1 < args.count {
                        qualitySpecified = true
                        switch args[i + 1] {
                        case "auto":
                            quality = .auto
                        case "standard":
                            quality = .standard
                        case "hd":
                            quality = .hd
                        case "high":
                            quality = .high
                        case "medium":
                            quality = .medium
                        case "low":
                            quality = .low
                        default:
                            print("Invalid quality: \(args[i + 1]). Using default: auto")
                            qualitySpecified = false
                        }
                        i += 1
                    }
                    
                case "style":
                    if i + 1 < args.count {
                        switch args[i + 1] {
                        case "vivid":
                            style = .vivid
                        case "natural":
                            style = .natural
                        default:
                            print("Invalid style: \(args[i + 1]). Using default: vivid")
                        }
                        i += 1
                    }
                    
                case "background":
                    if i + 1 < args.count {
                        switch args[i + 1] {
                        case "transparent":
                            background = .transparent
                        case "opaque":
                            background = .opaque
                        case "auto":
                            background = .auto
                        default:
                            print("Invalid background: \(args[i + 1]). Using default: auto")
                        }
                        i += 1
                    }
                    
                case "output-format":
                    if i + 1 < args.count {
                        switch args[i + 1] {
                        case "png":
                            outputFormat = .png
                        case "jpeg":
                            outputFormat = .jpeg
                        case "webp":
                            outputFormat = .webp
                        default:
                            print("Invalid output format: \(args[i + 1]). Using default: png")
                        }
                        i += 1
                    }
                    
                case "compression":
                    if i + 1 < args.count, let compression = Int(args[i + 1]), compression >= 0 && compression <= 100 {
                        outputCompression = compression
                        i += 1
                    } else {
                        print("Invalid compression value. Should be 0-100. Using default: 100")
                    }
                    
                case "moderation":
                    if i + 1 < args.count {
                        switch args[i + 1] {
                        case "low":
                            moderation = .low
                        case "auto":
                            moderation = .auto
                        default:
                            print("Invalid moderation level: \(args[i + 1]). Using default: auto")
                        }
                        i += 1
                    }
                    
                default:
                    print("Unknown option: \(option)")
                }
            } else {
                // If not an option, treat as part of the prompt
                prompt += (prompt.isEmpty ? "" : " ") + arg
            }
            
            i += 1
        }
        
        if prompt.isEmpty {
            print("Error: Please provide a prompt")
            printUsage()
            exit(1)
        }
        
        // Automatically set appropriate quality value based on the model if not explicitly specified
        if !qualitySpecified {
            if model == .dallE3 {
                quality = .standard  // Default for DALL-E 3
            } else if model == .dallE2 {
                quality = .standard  // Only option for DALL-E 2
            } else if model == .gptImage1 {
                quality = .auto  // Default for gpt-image-1
            }
        }
        
        // Print the configuration
        print("Creating image with the following parameters:")
        print("- Prompt: \(prompt)")
        print("- Model: \(model.rawValue)")
        print("- Number of images: \(n)")
        print("- Size: \(size.rawValue)")
        print("- Quality: \(quality.rawValue)")
        
        if model == .dallE3, let style = style {
            print("- Style: \(style.rawValue)")
        }
        
        if let background = background {
            print("- Background: \(background.rawValue)")
        }
        
        if let outputFormat = outputFormat {
            print("- Output format: \(outputFormat.rawValue)")
        }
        
        if let outputCompression = outputCompression {
            print("- Output compression: \(outputCompression)%")
        }
        
        if let moderation = moderation {
            print("- Moderation level: \(moderation.rawValue)")
        }
        
        print("\nGenerating image(s)... This may take a few moments.")
        
        // Generate the image
        do {
            let response = try await client.createImage(
                prompt: prompt,
                model: model,
                n: n,
                quality: quality,
                size: size,
                style: style,
                background: background,
                outputFormat: outputFormat,
                outputCompression: outputCompression,
                moderation: moderation
            )
            
            print("\n✓ Image creation successful!")
            print("- Created at: \(Date(timeIntervalSince1970: TimeInterval(response.created)))")
            print("- Number of images returned: \(response.data.count)")
            
            // Print image URLs or base64 data info
            for (index, imageData) in response.data.enumerated() {
                if let url = imageData.url {
                    print("\nImage \(index + 1) URL:")
                    print(url)
                } else if imageData.b64Json != nil {
                    print("\nImage \(index + 1): Base64 data available")
                }
                
                if let revisedPrompt = imageData.revisedPrompt {
                    print("\nRevised prompt for image \(index + 1):")
                    print(revisedPrompt)
                }
            }
            
            // Print token usage if available
            if let usage = response.usage {
                print("\nToken Usage:")
                print("- Total tokens: \(usage.totalTokens)")
                print("- Input tokens: \(usage.inputTokens)")
                print("- Output tokens: \(usage.outputTokens)")
                
                if let details = usage.inputTokensDetails {
                    print("- Text tokens: \(details.textTokens)")
                    print("- Image tokens: \(details.imageTokens)")
                }
            }
            
        } catch {
            print("\n❌ Error: \(error)")
            print("Error details: \(error.localizedDescription)")
            exit(1)
        }
    }
    
    // Helper function to print usage information
    static func printUsage() {
        print("""
        
        OpenAIImagesCLI - Demo for OpenAIImagesKit
        
        Usage:
          OpenAIImagesCLI create [options] "your prompt here"
          OpenAIImagesCLI help
        
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
        
        Examples:
          OpenAIImagesCLI create "A cute baby sea otter floating on its back in blue water"
          OpenAIImagesCLI create --model gpt-image-1 --size 1536x1024 --quality high "Mountain landscape at sunset"
          OpenAIImagesCLI create --background transparent --output-format webp --compression 90 "A red apple on white background"
        
        Note: Set your OPENAI_API_KEY environment variable before running.
        
        """)
    }
}