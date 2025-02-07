package com.juandpt.flutter_mediapipe_chat

data class ModelConfig(
    val path: String,
    val temperature: Float = 0.8f,
    val maxTokens: Int = 1024,
    val topK: Int = 40,
    val randomSeed: Int = 0,
    val loraPath: String? = null,
    val supportedLoraRanks: List<Int>? = null
) {
    companion object {
        fun fromMap(map: Map<*, *>): ModelConfig {
            val path = map["path"] as? String ?: throw IllegalArgumentException("Missing 'path'")
            val temperature = (map["temperature"] as? Number)?.toFloat() ?: 0.8f
            val maxTokens = (map["maxTokens"] as? Number)?.toInt() ?: 1024
            val topK = (map["topK"] as? Number)?.toInt() ?: 40
            val randomSeed = (map["randomSeed"] as? Number)?.toInt() ?: 0
            val loraPath = map["loraPath"] as? String
            val supportedLoraRanks = (map["supportedLoraRanks"] as? List<*>)?.mapNotNull { (it as? Number)?.toInt() }
            return ModelConfig(path, temperature, maxTokens, topK, randomSeed, loraPath, supportedLoraRanks)
        }
    }
}
