import Flutter
import Foundation
import MediaPipeTasksGenAI
import MediaPipeTasksGenAIC

@available(iOS 13.0, *)
class InferenceController {
    private var inferenceModel: InferenceModel?
    private var temperature: Float
    private var randomSeed: Int
    private var topK: Int
    private var supportedLoraRanks: [Int]?
    private var loraPath: String?
    private var inferenceSession: InferenceSession?
    private var eventSink: FlutterEventSink?

    init(config: ModelConfig) throws {
        self.temperature = config.temperature
        self.topK = config.topK
        self.randomSeed = config.randomSeed
        self.supportedLoraRanks = config.supportedLoraRanks
        self.loraPath = config.loraPath
        let modelFilePath = (config.loraPath?.isEmpty == false) ? config.loraPath! : config.path
        self.inferenceModel = try InferenceModel(modelPath: modelFilePath, maxTokens: config.maxTokens, supportedLoraRanks: config.supportedLoraRanks)
    }

    func generateResponse(prompt: String) throws -> String {
        if inferenceSession != nil {
            inferenceSession = nil
        }
        inferenceSession = try InferenceSession(
            inference: inferenceModel!.inference,
            temperature: temperature,
            randomSeed: randomSeed,
            topK: topK,
            loraPath: loraPath)
        return try inferenceSession!.generateResponse(prompt: prompt)
    }

    func generateResponseStream(prompt: String) async throws {
        if inferenceSession != nil {
            inferenceSession = nil
        }
        inferenceSession = try InferenceSession(
            inference: inferenceModel!.inference,
            temperature: temperature,
            randomSeed: randomSeed,
            topK: topK,
            loraPath: loraPath)
        let responseStream = try inferenceSession!.generateResponseAsync(prompt: prompt)
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

    func close() {
        inferenceModel = nil
        inferenceSession = nil
    }
}