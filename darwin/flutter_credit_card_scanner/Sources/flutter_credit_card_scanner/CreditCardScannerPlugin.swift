import Flutter
import UIKit
import Vision

public class CreditCardScannerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "flutter_credit_card_scanner/recognize_text",
      binaryMessenger: registrar.messenger()
    )
    let instance = CreditCardScannerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "recognize" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard let arguments = call.arguments as? [String: Any],
      let data = arguments["image"] as? FlutterStandardTypedData,
      let width = intValue(arguments["width"]),
      let height = intValue(arguments["height"])
    else {
      result(FlutterError(code: "bad_args", message: "Missing image data", details: nil))
      return
    }

    let rotation = intValue(arguments["rotation"]) ?? 0
    let bytes = Data(data.data)
    let imageSize = CGSize(width: width, height: height)
    let orientation = orientation(for: rotation)
    let handler: VNImageRequestHandler
    if bytes.count == width * height * 4 {
      let image = CIImage(
        bitmapData: bytes,
        bytesPerRow: width * 4,
        size: imageSize,
        format: .BGRA8,
        colorSpace: nil
      )
      handler = VNImageRequestHandler(ciImage: image, orientation: orientation)
    } else {
      handler = VNImageRequestHandler(data: bytes, orientation: orientation)
    }

    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.recognitionLanguages = ["en-US"]
    if #available(iOS 16.0, *) {
      request.automaticallyDetectsLanguage = false
    }

    do {
      try handler.perform([request])
      let lines = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
      result(lines)
    } catch {
      result(FlutterError(code: "recognize", message: error.localizedDescription, details: nil))
    }
  }

  private func intValue(_ value: Any?) -> Int? {
    if let number = value as? Int {
      return number
    }
    if let number = value as? NSNumber {
      return number.intValue
    }
    return nil
  }

  /// Matches the orientations the previous Apple Vision call used for each sensor rotation.
  private func orientation(for rotation: Int) -> CGImagePropertyOrientation {
    switch rotation {
    case 180:
      return .down
    case 270:
      return .downMirrored
    default:
      return .up
    }
  }
}
