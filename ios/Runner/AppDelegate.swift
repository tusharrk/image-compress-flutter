import Flutter
import UIKit
import ImageIO
import UniformTypeIdentifiers
import MobileCoreServices // Required for legacy support

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let channelName = "image_compressor_ios"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "compressImage", "calculateSize":
                self.handleCompression(call: call, result: result, isCalculation: call.method == "calculateSize")
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

 private func handleCompression(call: FlutterMethodCall, result: @escaping FlutterResult, isCalculation: Bool) {
        let methodType = isCalculation ? "[CALC]" : "[COMPRESS]"
        
        guard let args = call.arguments as? [String: Any],
              let originalData = (args["originalImage"] as? FlutterStandardTypedData)?.data,
              let quality = args["quality"] as? Double,
              let width = args["width"] as? Int,
              let height = args["height"] as? Int,
              let format = args["format"] as? String,
              let keepExif = args["keepExif"] as? Bool,
              let keepLocation = args["keepLocation"] as? Bool,
              let sourceFileName = args["sourceFileName"] as? String else {
            print("DEBUG_SWIFT \(methodType): ❌ Invalid Args")
            result(FlutterError(code: "INVALID", message: "Invalid args", details: nil)); return
        }

        print("DEBUG_SWIFT \(methodType): START processing. FileName: '\(sourceFileName)', Bytes: \(originalData.count), Format: \(format)")

        DispatchQueue.global(qos: .userInitiated).async {
            if let data = self.processImage(
                originalData: originalData,
                quality: quality,
                width: width,
                height: height,
                format: format,
                keepExif: keepExif,
                keepLocation: keepLocation,
                sourceFileName: sourceFileName,
                logPrefix: methodType
            ) {
                
                // --- START: "DON'T GROW" LOGIC ---
                var finalData = data
                
                // Only apply this check if the user selected "original" format (meaning keep same extension)
                // If user explicitly converted HEIC -> JPEG, size increase is expected, so we don't block it.
                if format == "original" {
                    if data.count > originalData.count {
                        print("DEBUG_SWIFT \(methodType): ⚠️ Result (\(data.count)) is larger than Input (\(originalData.count)). Returning Input.")
                        finalData = originalData
                    }
                }
                // --- END: "DON'T GROW" LOGIC ---
                
                print("DEBUG_SWIFT \(methodType): ✅ SUCCESS. Final Bytes: \(finalData.count)")
                
                if isCalculation {
                    result(finalData.count)
                } else {
                    result(FlutterStandardTypedData(bytes: finalData))
                }
            } else {
                print("DEBUG_SWIFT \(methodType): ❌ FAILED to process image")
                result(FlutterError(code: "FAIL", message: "Compression failed", details: nil))
            }
        }
    }

    private func processImage(
        originalData: Data,
        quality: Double,
        width: Int,
        height: Int,
        format: String,
        keepExif: Bool,
        keepLocation: Bool,
        sourceFileName: String,
        logPrefix: String
    ) -> Data? {
        
        // 1. Attempt Resize
        guard let resized = self.resizedCGImage(from: originalData, width: width, height: height) else {
            print("DEBUG_SWIFT \(logPrefix): ⚠️ Resize failed. Fallback to original CGImage.")
            // Fallback: try to get image directly without resizing
            guard let src = CGImageSourceCreateWithData(originalData as CFData, nil),
                  let cg = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
                print("DEBUG_SWIFT \(logPrefix): ❌ Could not create CGImageSource from data.")
                return nil
            }
            return encodeImage(cgImage: cg, originalData: originalData, quality: quality, format: format, keepExif: keepExif, keepLocation: keepLocation, sourceFileName: sourceFileName, logPrefix: logPrefix)
        }

        // 2. Encode
        return encodeImage(cgImage: resized, originalData: originalData, quality: quality, format: format, keepExif: keepExif, keepLocation: keepLocation, sourceFileName: sourceFileName, logPrefix: logPrefix)
    }

    private func resizedCGImage(from data: Data, width: Int, height: Int) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let srcImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue
        let bytesPerRow = width * 4

        guard let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }

        ctx.interpolationQuality = .high
        ctx.draw(srcImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return ctx.makeImage()
    }

private func encodeImage(
        cgImage: CGImage,
        originalData: Data,
        quality: Double,
        format: String,
        keepExif: Bool,
        keepLocation: Bool, // This might be true even if keepExif is false
        sourceFileName: String,
        logPrefix: String
    ) -> Data? {
        // 1. Determine Source UTI
        var sourceUTI: CFString? = nil
        if let src = CGImageSourceCreateWithData(originalData as CFData, nil) {
            sourceUTI = CGImageSourceGetType(src)
        }
        
        print("DEBUG_SWIFT \(logPrefix): Detected Source UTI: \(String(describing: sourceUTI))")

        // 2. Determine Destination UTI
        let destUTI = destinationUTI(for: format, sourceUTI: sourceUTI, filename: sourceFileName)
        print("DEBUG_SWIFT \(logPrefix): Selected Destination UTI: \(destUTI)")

        let outData = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(outData, destUTI, 1, nil) else {
            print("DEBUG_SWIFT \(logPrefix): ⚠️ Failed to create destination. Falling back to JPEG.")
            return encodeAsJPEG(cgImage: cgImage, originalData: originalData, quality: quality, keepExif: keepExif, keepLocation: keepLocation)
        }

        // 3. Metadata Logic
        // We enter this block if we need Exif OR Location
        if (keepExif || keepLocation),
           let src = CGImageSourceCreateWithData(originalData as CFData, nil),
           let originalMeta = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any] {
            
            var finalMeta: [CFString: Any] = [:]
            
            if keepExif {
                // Case A: User wants ALL metadata (and maybe location)
                finalMeta = originalMeta
                if !keepLocation {
                    // User wants Exif but NO location -> Remove GPS
                    finalMeta.removeValue(forKey: kCGImagePropertyGPSDictionary)
                }
            } else {
                // Case B: User does NOT want Exif, but DOES want Location
                // Start with empty dict, copy ONLY GPS from original
                if let gps = originalMeta[kCGImagePropertyGPSDictionary] {
                    finalMeta[kCGImagePropertyGPSDictionary] = gps
                }
            }
            
            // CRITICAL: Always inject quality into the metadata dictionary
            if destUTI != UTType.png.identifier as CFString {
                finalMeta[kCGImageDestinationLossyCompressionQuality] = quality
            }
            
            CGImageDestinationAddImage(dest, cgImage, finalMeta as CFDictionary)
            
        } else {
            // Case C: User wants clean image (No Exif, No Location)
            var props: [CFString: Any] = [:]
            if destUTI != UTType.png.identifier as CFString {
                props[kCGImageDestinationLossyCompressionQuality] = quality
            }
            CGImageDestinationAddImage(dest, cgImage, props as CFDictionary)
        }

        if !CGImageDestinationFinalize(dest) {
            print("DEBUG_SWIFT \(logPrefix): ⚠️ Finalize failed. Falling back to JPEG.")
            return encodeAsJPEG(cgImage: cgImage, originalData: originalData, quality: quality, keepExif: keepExif, keepLocation: keepLocation)
        }

        return outData as Data
    }

    private func encodeAsJPEG(cgImage: CGImage, originalData: Data, quality: Double, keepExif: Bool, keepLocation: Bool) -> Data? {
        let out = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(out, UTType.jpeg.identifier as CFString, 1, nil) else { return nil }

        // Apply the same selective logic for fallback JPEG
        if (keepExif || keepLocation),
           let src = CGImageSourceCreateWithData(originalData as CFData, nil),
           let originalMeta = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any] {
            
            var finalMeta: [CFString: Any] = [:]
            
            if keepExif {
                finalMeta = originalMeta
                if !keepLocation {
                    finalMeta.removeValue(forKey: kCGImagePropertyGPSDictionary)
                }
            } else {
                // keepExif is false, but keepLocation is true
                if let gps = originalMeta[kCGImagePropertyGPSDictionary] {
                    finalMeta[kCGImagePropertyGPSDictionary] = gps
                }
            }
            
            // Always add quality
            finalMeta[kCGImageDestinationLossyCompressionQuality] = quality
            CGImageDestinationAddImage(dest, cgImage, finalMeta as CFDictionary)
            
        } else {
            var props: [CFString: Any] = [:]
            props[kCGImageDestinationLossyCompressionQuality] = quality
            CGImageDestinationAddImage(dest, cgImage, props as CFDictionary)
        }
        
        return CGImageDestinationFinalize(dest) ? out as Data : nil
    }

    private func destinationUTI(for format: String, sourceUTI: CFString?, filename: String) -> CFString {
        let f = format.lowercased()
        
        // Helper to check heic
        let isHeic = { (s: String) -> Bool in
            return s == "public.heic" || s == "public.heif" || s == "org.iphone.heic" || s.hasSuffix("heic")
        }

        switch f {
        case "original":
            // 1. Try Source UTI
            if let s = sourceUTI {
                let sStr = s as String
                if isHeic(sStr) {
                     if #available(iOS 14.0, *) { return UTType.heic.identifier as CFString }
                     return "public.heic" as CFString
                }
                if sStr == "org.webmproject.webp" || sStr == "public.webp" { return "public.webp" as CFString }
                return s
            }
            
            // 2. Fallback: Try Filename
            // IMPORTANT: This fails if filename is empty!
            if filename.lowercased().hasSuffix(".heic") {
                 if #available(iOS 14.0, *) { return UTType.heic.identifier as CFString }
                 return "public.heic" as CFString
            }
            
            return UTType.jpeg.identifier as CFString

        case "jpeg": return UTType.jpeg.identifier as CFString
        case "png": return UTType.png.identifier as CFString
        case "webp": return "public.webp" as CFString
        case "heic":
            if #available(iOS 14.0, *) { return UTType.heic.identifier as CFString }
            return UTType.jpeg.identifier as CFString
        default: return UTType.jpeg.identifier as CFString
        }
    }
}