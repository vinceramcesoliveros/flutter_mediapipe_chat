part of 'flutter_mediapipe_chat.dart';

/// The base platform interface for FlutterMediapipeChat.

/// This class defines the API that must be implemented for both Android and iOS
/// using method channels and event channels.
abstract class FlutterMediapipeChatPlatform extends PlatformInterface {
  FlutterMediapipeChatPlatform() : super(token: _token);

  static final Object _token = Object();
  static FlutterMediapipeChatPlatform _instance =
      MethodChannelFlutterMediapipeChat();

  /// The default instance of [FlutterMediapipeChatPlatform] to use.
  static FlutterMediapipeChatPlatform get instance => _instance;

  static set instance(FlutterMediapipeChatPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Loads the model using the provided [config].
  Future<void> loadModel(ModelConfig config);

  /// Synchronously generates a response for the given [prompt].
  Future<String?> generateResponse(String prompt);

  /// Generates a response in streaming mode for the given [prompt].
  Stream<String> generateResponseAsync(String prompt);
}
