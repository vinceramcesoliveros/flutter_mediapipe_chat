class ModelConfig {
  final String path;
  final double temperature;
  final int maxTokens;
  final int topK;
  final int randomSeed;

  ModelConfig({
    required this.path,
    this.temperature = 0.8,
    this.maxTokens = 1024,
    this.topK = 40,
    this.randomSeed = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "path": path,
      "temperature": temperature,
      "maxTokens": maxTokens,
      "topK": topK,
      "randomSeed": randomSeed,
    };
  }

  factory ModelConfig.fromMap(Map<String, dynamic> map) {
    return ModelConfig(
      path: map["path"],
      temperature: map["temperature"] ?? 0.8,
      maxTokens: map["maxTokens"] ?? 1024,
      topK: map["topK"] ?? 40,
      randomSeed: map["randomSeed"] ?? 0,
    );
  }
}
