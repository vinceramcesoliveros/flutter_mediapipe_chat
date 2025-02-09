part of 'flutter_mediapipe_chat.dart';

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
  Stream<String> generateResponseAsync(String prompt);
}
