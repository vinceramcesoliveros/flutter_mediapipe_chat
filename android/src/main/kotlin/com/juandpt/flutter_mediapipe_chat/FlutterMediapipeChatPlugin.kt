package com.juandpt.flutter_mediapipe_chat

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class FlutterMediapipeChatPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private var inferenceModel: InferenceModel? = null
    private lateinit var context: Context
    private val scope = CoroutineScope(Dispatchers.Main)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "flutter_mediapipe_chat/methods")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "flutter_mediapipe_chat/events")
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "loadModel" -> {
                try {
                    val map = call.arguments as Map<*, *>
                    val config = ModelConfig.fromMap(map)
                    inferenceModel = InferenceModel.getInstance(context, config)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("MODEL_LOAD_ERROR", e.localizedMessage, null)
                }
            }
            "generateResponse" -> {
                try {
                    val prompt = call.argument<String>("prompt") ?: throw IllegalArgumentException("Missing 'prompt'")
                    val response = inferenceModel?.generateResponse(prompt)
                    result.success(response)
                } catch (e: Exception) {
                    result.error("INFERENCE_ERROR", e.localizedMessage, null)
                }
            }
            "generateResponseAsync" -> {
                try {
                    val prompt = call.argument<String>("prompt") ?: throw IllegalArgumentException("Missing 'prompt'")
                    inferenceModel?.generateResponseAsync(prompt)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("INFERENCE_ERROR", e.localizedMessage, null)
                }
            }
            "close" -> {
                inferenceModel?.close()
                inferenceModel = null
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        inferenceModel?.let { model ->
            scope.launch {
                model.partialResults.collect { pair ->
                    eventSink?.success(pair.first)
                    if (pair.second) {
                        eventSink?.success(null)
                    }
                }
            }
            scope.launch {
                model.errors.collect { error ->
                    eventSink?.error("ERROR", error.message, null)
                }
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}
