import Foundation
import MediaPipeTasksGenAI
import MediaPipeTasksGenAIC

final class InferenceSession {
    private let session: LlmInference.Session

    static func createInferenceModel(config: ModelConfig) throws -> LlmInference {
        let options = LlmInference.Options(modelPath: config.path)
        options.maxTokens = config.maxTokens
        return try LlmInference(options: options)
    }

    init(inference: LlmInference, config: ModelConfig) throws {
        let options = LlmInference.Session.Options()
        options.temperature = config.temperature
        options.topk = config.topK
        options.randomSeed = config.randomSeed
        self.session = try LlmInference.Session(llmInference: inference, options: options)
    }

    init(inference: LlmInference, temperature: Float, randomSeed: Int, topK: Int, loraPath: String? = nil) throws {
        let options = LlmInference.Session.Options()
        options.temperature = temperature
        options.randomSeed = randomSeed
        options.topk = topK
        self.session = try LlmInference.Session(llmInference: inference, options: options)
    }

    func generateResponse(prompt: String) throws -> String {
        try session.addQueryChunk(inputText: prompt)
        return try session.generateResponse()
    }

    @available(iOS 13.0.0, *)
    func generateResponseAsync(prompt: String) throws -> AsyncThrowingStream<String, any Error> {
        try session.addQueryChunk(inputText: prompt)
        return session.generateResponseAsync()
    }
}