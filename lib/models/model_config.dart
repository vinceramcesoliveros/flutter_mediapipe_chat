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
