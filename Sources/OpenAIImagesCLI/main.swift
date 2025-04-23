import Foundation
import OpenAIImagesKit

// Simple command-line tool to demonstrate OpenAIImagesKit

@main
struct OpenAIImagesCLI {
    static func main() async {
        // You would typically get this from environment or a secure store
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
            if args.count < 3 {
                print("Error: Please provide a prompt")
                printUsage()
                exit(1)
            }
            
            let prompt = args[2]
            
            print("Creating image with prompt: \(prompt)")
            print("Using model: gpt-image-1 (default)")
            print("This may take a few moments...")
            
            do {
                let response = try await client.createImage(prompt: prompt)
                
                if let url = response.data.first?.url {
                    print("✓ Image created successfully!")
                    print("URL: \(url)")
                } else {
                    print("✓ Image created but no URL was returned (unusual)")
                }
                
                if let revisedPrompt = response.data.first?.revisedPrompt {
                    print("\nRevised prompt: \(revisedPrompt)")
                }
            } catch {
                print("❌ Error: \(error.localizedDescription)")
            }
            
        case "help":
            printUsage()
            
        default:
            print("Unknown command: \(command)")
            printUsage()
            exit(1)
        }
    }
    
    // Helper function to print usage information
    static func printUsage() {
        print("""
        
        OpenAIImagesCLI - Demo for OpenAIImagesKit
        
        Usage:
          OpenAIImagesCLI create "your prompt here"
          OpenAIImagesCLI help
        
        Examples:
          OpenAIImagesCLI create "A cute baby sea otter floating on its back in blue water"
        
        Note: Set your OPENAI_API_KEY environment variable before running.
        
        """)
    }
}