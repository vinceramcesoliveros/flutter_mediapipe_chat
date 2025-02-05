
import Foundation

struct ModelConfig {
    let path: String
    let temperature: Float
    let maxTokens: Int
    let topK: Int
    let randomSeed: Int
    let loraPath: String?
    let supportedLoraRanks: [Int]?

    init(dictionary: [String: Any]) throws {
        guard let path = dictionary["path"] as? String else {
            throw NSError(domain: "ModelConfigError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing model path"])
        }
        self.path = path
        self.temperature = dictionary["temperature"] as? Float ?? 0.8
        self.maxTokens = dictionary["maxTokens"] as? Int ?? 1024
        self.topK = dictionary["topK"] as? Int ?? 40
        self.randomSeed = dictionary["randomSeed"] as? Int ?? 0
        self.loraPath = dictionary["loraPath"] as? String
        self.supportedLoraRanks = dictionary["supportedLoraRanks"] as? [Int]
    }
}
