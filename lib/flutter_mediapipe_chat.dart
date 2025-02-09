library;

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'model_config.dart';
part 'flutter_mediapipe_chat_platform_interface.dart';
part 'flutter_mediapipe_chat_method_channel.dart';

/// The main class for using the FlutterMediapipeChat plugin.
///
/// Provides methods to load the model and generate responses either synchronously
/// or in streaming mode.
class FlutterMediapipeChat {
  /// Loads the LLM model based on the given [config].
  Future<void> loadModel(ModelConfig config) {
    return FlutterMediapipeChatPlatform.instance.loadModel(config);
  }

  /// Generates a synchronous response for the provided [prompt].
  Future<String?> generateResponse(String prompt) {
    return FlutterMediapipeChatPlatform.instance.generateResponse(prompt);
  }

  /// Generates a response in streaming mode for the provided [prompt].
  Stream<String> generateResponseAsync(String prompt) {
    return FlutterMediapipeChatPlatform.instance.generateResponseAsync(prompt);
  }
}
