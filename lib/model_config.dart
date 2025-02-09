part of 'flutter_mediapipe_chat.dart';

/// A configuration class for the inference model.
///
/// Contains parameters such as:
/// - [path]: The path to the model file.
/// - [temperature]: Controls the creativity of the response.
/// - [maxTokens]: Maximum number of tokens to generate.
/// - [topK]: Sampling parameter for response generation.
/// - [randomSeed]: Seed for randomness.
/// - [loraPath] and [supportedLoraRanks]: Optional parameters for fine-tuning.
class ModelConfig {
  final String path;
  final double temperature;
  final int maxTokens;
  final int topK;
  final int randomSeed;
  final String? loraPath;
  final List<int>? supportedLoraRanks;

  ModelConfig({
    required this.path,
    this.temperature = 0.8,
    this.maxTokens = 1024,
    this.topK = 40,
    this.randomSeed = 0,
    this.loraPath,
    this.supportedLoraRanks,
  });

  /// Converts this [ModelConfig] into a [Map] for use with native code.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'path': path,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'topK': topK,
      'randomSeed': randomSeed,
    };
    if (loraPath != null) {
      map['loraPath'] = loraPath;
    }
    if (supportedLoraRanks != null) {
      map['supportedLoraRanks'] = supportedLoraRanks;
    }
    return map;
  }
}
