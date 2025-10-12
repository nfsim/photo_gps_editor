import Flutter
import ImageIO
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = self.window?.rootViewController as? FlutterViewController {
      let exifChannel = FlutterMethodChannel(
        name: "com.example.photo_gps_editor/exif", binaryMessenger: controller.binaryMessenger)
      exifChannel.setMethodCallHandler { call, result in
        switch call.method {
        case "setExifGPS":
          if let args = call.arguments as? [String: Any],
            let path = args["path"] as? String,
            let latitude = args["latitude"] as? Double,
            let longitude = args["longitude"] as? Double,
            let altitude = args["altitude"] as? Double
          {
            if self.setGPSForImage(
              path: path, latitude: latitude, longitude: longitude, altitude: altitude)
            {
              result(true)
            } else {
              result(FlutterError(code: "EXIF_ERROR", message: "Failed to set GPS", details: nil))
            }
          } else {
            result(
              FlutterError(code: "INVALID_ARGUMENTS", message: "Missing arguments", details: nil))
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func setGPSForImage(path: String, latitude: Double, longitude: Double, altitude: Double) -> Bool {
    let url = URL(fileURLWithPath: path)
    guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
      return false
    }

    guard let imageData = CGImageSourceGetType(imageSource) else {
      return false
    }

    // Create destination
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, imageData, 1, nil) else {
      return false
    }

    guard let properties = CGImageSourceCopyMetadataAtIndex(imageSource, 0, nil) else {
      return false
    }

    let mutableMeta = CGImageMetadataCreateMutableCopy(properties)!

    // GPS data
    let gpsDictionary: NSDictionary = [
      kCGImagePropertyGPSLatitude: abs(latitude),
      kCGImagePropertyGPSLatitudeRef: latitude >= 0 ? "N" : "S",
      kCGImagePropertyGPSLongitude: abs(longitude),
      kCGImagePropertyGPSLongitudeRef: longitude >= 0 ? "E" : "W",
      kCGImagePropertyGPSAltitude: altitude,
      kCGImagePropertyGPSAltitudeRef: altitude >= 0 ? 0 : 1,
    ]

    CGImageMetadataSetValue(
      mutableMeta, kCFNull, kCGImagePropertyGPSDictionary as CFString, gpsDictionary)

    CGImageDestinationAddImageFromSource(destination, imageSource, 0, mutableMeta)

    CGImageDestinationFinalize(destination)

    return true
  }
}
