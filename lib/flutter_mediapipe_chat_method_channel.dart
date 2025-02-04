import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_mediapipe_chat/models/models.dart';
import 'flutter_mediapipe_chat_platform_interface.dart';

class MethodChannelFlutterMediapipeChat extends FlutterMediapipeChatPlatform {
  final methodChannel = const MethodChannel('flutter_mediapipe_chat/methods');
  final eventChannel = const EventChannel('flutter_mediapipe_chat/events');

  @override
  Future<void> loadModel(ModelConfig config) async {
    await methodChannel.invokeMethod('loadModel', config.toMap());
  }

  @override
  Future<String?> generateResponse(String prompt) async {
    return await methodChannel
        .invokeMethod('generateResponse', {"prompt": prompt});
  }

  @override
  Stream<String> generateResponseStream(String prompt) {
    methodChannel.invokeMethod('generateResponseStream', {"prompt": prompt});
    return eventChannel
        .receiveBroadcastStream()
        .map((event) => event as String);
  }
}
