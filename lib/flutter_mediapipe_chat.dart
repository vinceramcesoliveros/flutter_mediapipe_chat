import 'dart:async';
import 'package:flutter_mediapipe_chat/models/model_config.dart';

import 'flutter_mediapipe_chat_platform_interface.dart';

class FlutterMediapipeChat {
  Future<void> loadModel(ModelConfig config) {
    return FlutterMediapipeChatPlatform.instance.loadModel(config);
  }

  Future<String?> generateResponse(String prompt) {
    return FlutterMediapipeChatPlatform.instance.generateResponse(prompt);
  }

  Stream<String> generateResponseStream(String prompt) {
    return FlutterMediapipeChatPlatform.instance.generateResponseStream(prompt);
  }
}
