import Foundation
import Flutter
import MediaPipeTasksGenAI
import MediaPipeTasksGenAIC

@available(iOS 13.0, *)
class InferenceController {
    private var inference: LlmInference?
    private var eventSink: FlutterEventSink?
    private var config: ModelConfig

    init(config: ModelConfig) throws {
        self.config = config
        self.inference = try InferenceSession.createInferenceModel(config: config)
    }

    func generateResponse(prompt: String) throws -> String {
        let session = try InferenceSession(inference: inference!, config: config)
        return try session.generateResponse(prompt: prompt)
    }

    func generateResponseStream(prompt: String) async throws {
        let session = try InferenceSession(inference: inference!, config: config)
        let responseStream = try session.generateResponseAsync(prompt: prompt)

        for try await token in responseStream {
            DispatchQueue.main.async {
                self.eventSink?(token)
            }
        }

        DispatchQueue.main.async {
            self.eventSink?(nil)
        }
    }

    func setEventSink(eventSink: @escaping FlutterEventSink) {
        self.eventSink = eventSink
    }

    func clearEventSink() {
        self.eventSink = nil
    }
}
