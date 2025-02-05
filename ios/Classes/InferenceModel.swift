import Foundation
import MediaPipeTasksGenAI
import MediaPipeTasksGenAIC

struct InferenceModel {
    private(set) var inference: LlmInference

    init(modelPath: String, maxTokens: Int, supportedLoraRanks: [Int]?) throws {
        let llmOptions = LlmInference.Options(modelPath: modelPath)
        llmOptions.maxTokens = maxTokens
        if let supportedLoraRanks = supportedLoraRanks {
            llmOptions.supportedLoraRanks = supportedLoraRanks
        }
        self.inference = try LlmInference(options: llmOptions)
    }
}