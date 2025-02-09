part of 'flutter_mediapipe_chat.dart';

/// An implementation of [FlutterMediapipeChatPlatform] that uses
/// a [MethodChannel] and an [EventChannel] for communicating with native code.
class MethodChannelFlutterMediapipeChat extends FlutterMediapipeChatPlatform {
  final MethodChannel _methodChannel =
      const MethodChannel('flutter_mediapipe_chat/methods');
  final EventChannel _eventChannel =
      const EventChannel('flutter_mediapipe_chat/events');

  @override
  Future<void> loadModel(ModelConfig config) async {
    await _methodChannel.invokeMethod('loadModel', config.toMap());
  }

  @override
  Future<String?> generateResponse(String prompt) async {
    return await _methodChannel
        .invokeMethod('generateResponse', {"prompt": prompt});
  }

  @override
  Stream<String> generateResponseAsync(String prompt) {
    _methodChannel.invokeMethod('generateResponseAsync', {"prompt": prompt});
    return _eventChannel
        .receiveBroadcastStream()
        .map((event) => event as String);
  }
}
