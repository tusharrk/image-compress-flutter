import Flutter
import UIKit
import ImageIO
import MobileCoreServices

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { call, result in
            guard call.method == "addExifToImage",
                  let args = call.arguments as? [String: Any],
                  let originalData = (args["originalImage"] as? FlutterStandardTypedData)?.data,
                  let compressedData = (args["compressedImage"] as? FlutterStandardTypedData)?.data,
                  let keepLocation = args["keepLocation"] as? Bool
            else {
                result(FlutterError(code: "INVALID", message: "Invalid arguments", details: nil))
                return
            }

            guard let source = CGImageSourceCreateWithData(originalData as CFData, nil),
                  let originalMetadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
                  let image = UIImage(data: compressedData),
                  let cgImage = image.cgImage
            else {
                result(FlutterError(code: "DECODE_FAIL", message: "Failed to decode images", details: nil))
                return
            }

            var updatedMetadata = originalMetadata
            if !keepLocation {
                updatedMetadata.removeValue(forKey: kCGImagePropertyGPSDictionary)
            }

            let destData = NSMutableData()
            if let destination = CGImageDestinationCreateWithData(destData, kUTTypeJPEG, 1, nil) {
                CGImageDestinationAddImage(destination, cgImage, updatedMetadata as CFDictionary)
                CGImageDestinationFinalize(destination)
                result(FlutterStandardTypedData(bytes: destData as Data))
            } else {
                result(FlutterError(code: "EXIF_FAIL", message: "Could not create destination", details: nil))
            }
        }


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
