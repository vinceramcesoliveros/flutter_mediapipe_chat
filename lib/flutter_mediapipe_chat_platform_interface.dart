import 'dart:async';
import 'package:flutter_mediapipe_chat/models/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'flutter_mediapipe_chat_method_channel.dart';

abstract class FlutterMediapipeChatPlatform extends PlatformInterface {
  FlutterMediapipeChatPlatform() : super(token: _token);

  static final Object _token = Object();
  static FlutterMediapipeChatPlatform _instance =
      MethodChannelFlutterMediapipeChat();

  static FlutterMediapipeChatPlatform get instance => _instance;

  static set instance(FlutterMediapipeChatPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> loadModel(ModelConfig config);
  Future<String?> generateResponse(String prompt);
  Stream<String> generateResponseStream(String prompt);
}
