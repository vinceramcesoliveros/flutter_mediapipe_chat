library;

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'model_config.dart';
part 'flutter_mediapipe_chat_platform_interface.dart';
part 'flutter_mediapipe_chat_method_channel.dart';

class FlutterMediapipeChat {
  Future<void> loadModel(ModelConfig config) {
    return FlutterMediapipeChatPlatform.instance.loadModel(config);
  }

  Future<String?> generateResponse(String prompt) {
    return FlutterMediapipeChatPlatform.instance.generateResponse(prompt);
  }

  Stream<String> generateResponseAsync(String prompt) {
    return FlutterMediapipeChatPlatform.instance.generateResponseAsync(prompt);
  }
}
