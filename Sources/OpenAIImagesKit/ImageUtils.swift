import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum ImageFormat {
    case png
    case jpeg(compressionQuality: CGFloat)
    
    var mimeType: String {
        switch self {
        case .png:
            return "image/png"
        case .jpeg:
            return "image/jpeg"
        }
    }
}

public class ImageUtils {
    
    // Converts image data to base64 encoded string
    public static func dataToBase64(data: Data) -> String? {
        return data.base64EncodedString()
    }
    
    // Converts a base64 encoded string to Data
    public static func base64ToData(base64String: String) -> Data? {
        return Data(base64Encoded: base64String)
    }
    
    #if os(iOS) || os(macOS)
    // Convert UIImage or NSImage to Data with specified format
    #if os(iOS)
    public static func imageToData(_ image: UIImage, format: ImageFormat = .png) -> Data? {
        switch format {
        case .png:
            return image.pngData()
        case .jpeg(let compressionQuality):
            return image.jpegData(compressionQuality: compressionQuality)
        }
    }
    #elseif os(macOS)
    public static func imageToData(_ image: NSImage, format: ImageFormat = .png) -> Data? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let rep = NSBitmapImageRep(cgImage: cgImage)
        
        switch format {
        case .png:
            return rep.representation(using: .png, properties: [:])
        case .jpeg(let compressionQuality):
            return rep.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
        }
    }
    #endif
    
    // Load image from a file URL
    public static func loadImageFromFile(url: URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
    #endif
}