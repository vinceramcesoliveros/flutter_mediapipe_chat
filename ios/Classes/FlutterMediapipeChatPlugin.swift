import Flutter
import UIKit

@available(iOS 13.0, *)
public class FlutterMediapipeChatPlugin: NSObject, FlutterPlugin {
    private var inferenceController: InferenceController?
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "flutter_mediapipe_chat/methods", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "flutter_mediapipe_chat/events", binaryMessenger: registrar.messenger())
        let instance = FlutterMediapipeChatPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    @MainActor 
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "loadModel":
            guard let arguments = call.arguments as? [String: Any],
                  let config = try? ModelConfig(dictionary: arguments) else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid model configuration", details: nil))
                return
            }
            do {
                inferenceController = try InferenceController(config: config)
                result(true)
            } catch {
                result(FlutterError(code: "MODEL_LOAD_ERROR", message: error.localizedDescription, details: nil))
            }
        case "generateResponse":
            guard let arguments = call.arguments as? [String: Any],
                  let prompt = arguments["prompt"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Prompt is required", details: nil))
                return
            }
            do {
                let response = try inferenceController?.generateResponse(prompt: prompt)
                result(response)
            } catch {
                result(FlutterError(code: "INFERENCE_ERROR", message: error.localizedDescription, details: nil))
            }
        case "generateResponseStream":
            guard let arguments = call.arguments as? [String: Any],
                  let prompt = arguments["prompt"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Prompt is required", details: nil))
                return
            }
            Task {
                do {
                    try await inferenceController?.generateResponseStream(prompt: prompt)
                    DispatchQueue.main.async {
                        result(nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "INFERENCE_ERROR", message: error.localizedDescription, details: nil))
                    }
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

@available(iOS 13.0, *)
extension FlutterMediapipeChatPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        inferenceController?.setEventSink(eventSink: events)
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        inferenceController?.clearEventSink()
        return nil
    }
}