package com.juandpt.flutter_mediapipe_chat

import android.content.Context
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import java.io.File

class InferenceModel private constructor(
    context: Context,
    config: ModelConfig
) {
    private val llmInference: LlmInference
    private var session: LlmInferenceSession? = null
    private val _partialResults = MutableSharedFlow<Pair<String, Boolean>>(
        extraBufferCapacity = 1,
        onBufferOverflow = BufferOverflow.DROP_OLDEST
    )
    val partialResults: SharedFlow<Pair<String, Boolean>> = _partialResults.asSharedFlow()
    private val _errors = MutableSharedFlow<Throwable>(
        extraBufferCapacity = 1,
        onBufferOverflow = BufferOverflow.DROP_OLDEST
    )
    val errors: SharedFlow<Throwable> = _errors.asSharedFlow()

    init {
        val modelFile = File(config.path)
        if (!modelFile.exists()) {
            throw IllegalArgumentException("Modelo no encontrado en la ruta: ${config.path}")
        }
        val optionsBuilder = LlmInference.LlmInferenceOptions.builder()
            .setModelPath(config.path)
            .setMaxTokens(config.maxTokens)
            .setResultListener { result, done ->
                _partialResults.tryEmit(Pair(result, done))
            }
            .setErrorListener { error ->
                _errors.tryEmit(Exception(error.message))
            }
        config.supportedLoraRanks?.let { optionsBuilder.setSupportedLoraRanks(it) }
        val options = optionsBuilder.build()
        llmInference = LlmInference.createFromOptions(context, options)
        val sessionOptionsBuilder = LlmInferenceSession.LlmInferenceSessionOptions.builder()
            .setTemperature(config.temperature)
            .setRandomSeed(config.randomSeed)
            .setTopK(config.topK)
        if (!config.loraPath.isNullOrEmpty()) {
            sessionOptionsBuilder.setLoraPath(config.loraPath)
        }
        val sessionOptions = sessionOptionsBuilder.build()
        session = LlmInferenceSession.createFromOptions(llmInference, sessionOptions)
    }

    fun generateResponse(prompt: String): String? {
        return try {
            session?.addQueryChunk(prompt)
            session?.generateResponse()
        } catch (e: Exception) {
            _errors.tryEmit(e)
            null
        }
    }

    fun generateResponseAsync(prompt: String) {
        try {
            session?.addQueryChunk(prompt)
            session?.generateResponseAsync()
        } catch (e: Exception) {
            _errors.tryEmit(e)
        }
    }

    fun close() {
        session?.close()
        llmInference.close()
        instance = null
    }

    companion object {
        private var instance: InferenceModel? = null
        fun getInstance(context: Context, config: ModelConfig): InferenceModel {
            if (instance == null) {
                instance = InferenceModel(context, config)
            }
            return instance!!
        }
    }
}
