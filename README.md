# Flutter MediaPipe Chat

Flutter MediaPipe Chat enables the Flutter community to implement and test AI models locally on Android and iOS, leveraging Google MediaPipe. This solution performs all processing on the device, allowing optimized models to run natively on smartphones. Additionally, it supports training and deploying custom models, providing developers with greater control and opening the door to innovative applications.

## Getting Started

### Prerequisites

- **Android**: minSdkVersion **24** (required by MediaPipe).
- **iOS**: iOS **13.0** or later.

### Installation

To add the package from the console, run:

```sh
flutter pub add flutter_mediapipe_chat
```

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_mediapipe_chat: ^1.0.0
```

Then run:

```sh
flutter pub get
```

#### Android Setup

In your `android/app/build.gradle`, make sure to include:

```gradle
android {
   defaultConfig {
      minSdkVersion 24
   }
}
```

In `AndroidManifest.xml` (usually `android/app/src/main/AndroidManifest.xml`), after the `</activity>` tag, add:

```xml
<uses-native-library android:name="libOpenCL.so" android:required="false"/>
<uses-native-library android:name="libOpenCL-car.so" android:required="false"/>
<uses-native-library android:name="libOpenCL-pixel.so" android:required="false"/>
```

---

## Plugin Usage

After installation and setup, you can start using `flutter_mediapipe_chat`:

1. **Loading the Model**

```dart
import 'package:flutter_mediapipe_chat/flutter_mediapipe_chat.dart';

final chatPlugin = FlutterMediapipeChat();

final config = ModelConfig(
  path: "assets/models/gemma-2b-it-gpu-int8.bin",
  temperature: 0.7,
  maxTokens: 1024,
  topK: 50,
  randomSeed: 42,
  loraPath: null,
);

await chatPlugin.loadModel(config);
```

2. **Generate Responses (Synchronous)**

```dart
String? response = await chatPlugin.generateResponse("Hello, how are you?");
if (response != null) {
  print("Model Response: $response");
} else {
  print("No response from model.");
}
```

3. **Generate Responses (Streaming)**

```dart
chatPlugin
   .generateResponseAsync("Tell me a story about a brave knight.")
   .listen((token) {
  if (token == null) {
   print("Stream ended.");
  } else {
   print("Token: $token");
  }
});
```

### Example Project

Inside the `example/` folder there is a demo project showing model loading, a chat interface, and both synchronous and asynchronous text generation. To run it:

```sh
cd example
flutter run
```

---

## Overview

This plugin simplifies on-device local LLM inference (thanks to the [MediaPipe](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference?authuser=1) framework) in Flutter for **Android** and **iOS**, removing the need for cloud services.

> **Note**: The [MediaPipe LLM Inference](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference?authuser=1) API is **experimental** and under active development. Use of this API is subject to the [Generative AI Prohibited Use Policy](https://policies.google.com/terms/service-specific?hl=en_US).

---

## Key Features

1. **Local Inference**  
   Avoids network dependencies by running models **entirely on-device**.

2. **Cross-Platform**  
   Compatible with **Android** (API 24+) and **iOS** (13.0+).

3. **Flexible Generation**  
   Choose between **synchronous** or **asynchronous** response modes.

4. **Advanced Model Customization**  
   Adjust parameters like `temperature`, `maxTokens`, `topK`, `randomSeed`, and optional **LoRA** configurations.

5. **GPU/CPU Variants**  
   Select between CPU- or GPU-optimized variants (if the device supports it).

---

## Supported and Custom Models

### Built-In Supported Models

- **Gemma-2 2B** (2 billion parameters)  
  CPU/GPU in int8 variants.

- **Gemma 2B** (2 billion parameters)  
  CPU/GPU in int4/int8 variants.

- **Gemma 7B** (7 billion parameters, Web only on high-end devices)  
  GPU int8 variant.

Download these `.bin` models from [Kaggle (Gemma)](https://www.kaggle.com/models/google/gemma/tfLite) and load them with `FlutterMediapipeChat`.

### Other Supported Models (Require Conversion)

- **Falcon-1B**
- **StableLM-3B**
- **Phi-2**

They require a script to convert to `.bin` or `.tflite`. Check out the [AI Edge Torch Generative Library](https://github.com/google-ai-edge/ai-edge-torch) for PyTorch conversions.

---

### Converting Other PyTorch Models

If you have a custom PyTorch model, convert it using [AI Edge Torch Generative](https://github.com/google-ai-edge/ai-edge-torch):

1. Export your PyTorch model to `.tflite`.
2. Combine the `.tflite` file with tokenizer parameters into a single `.task`.
3. Provide the path in `ModelConfig.path`.

---

### Using LoRA (Low-Rank Adaptation)

LoRA allows inexpensive training of large models by only modifying certain internal ranks. It’s available on GPU backends for:

- Gemma (2B, Gemma-2 2B)
- Phi-2

#### Preparing LoRA Weights

1. Train LoRA weights for your base model.
2. Convert them with the MediaPipe library specifying the LoRA checkpoint, rank, and GPU backend.

#### Using LoRA in Flutter

```dart
ModelConfig(
  path: "assets/models/base_model_gpu.bin",
  loraPath: "assets/models/lora_model_gpu.bin",
  temperature: 0.8,
  maxTokens: 1024,
  topK: 40,
);
```

> **Note**: LoRA is only supported in `.bin` or `.tflite` GPU models, not CPU.

---

## Model Configuration Reference

| Field                | Type       | Default  | Description                                       |
| -------------------- | ---------- | -------- | ------------------------------------------------- |
| `path`               | String     | Required | Path to the base file (`.bin` or `.task`).        |
| `temperature`        | double     | 0.8      | Controls randomness/creativity.                   |
| `maxTokens`          | int        | 1024     | Maximum number of tokens (input + output).        |
| `topK`               | int        | 40       | Limits predictions to the K most probable tokens. |
| `randomSeed`         | int        | 0        | Seed for random text generation.                  |
| `loraPath`           | String?    | null     | Path to LoRA weights, GPU models only.            |
| `supportedLoraRanks` | List<int>? | null     | For specific LoRA ranks (advanced usage).         |

---

## Recommended Models & Downloads

- **Gemma-2 2B (8-bit, CPU/GPU)**
- **Gemma 2B (int4/int8, CPU/GPU)**
- **Gemma 7B (int8, GPU, Web Only)**

Consider also **Phi-2, StableLM-3B, Falcon-1B** after conversion.

---

## Contributing

Contributions are welcome! Send pull requests on GitHub. For questions or feature requests, open an issue in the repository’s tracker.

---

## Legal & License

Licensed under MIT (see LICENSE). Third-party models (e.g., Falcon, StableLM, Phi-2) are not Google services. Make sure to comply with their licenses.  
Use of MediaPipe LLM Inference is governed by the [Generative AI Prohibited Use Policy](https://policies.google.com/terms/service-specific?hl=en_US).  
Gemma is an open family of models derived from the same research as Gemini, subject to licensing terms on Kaggle.

---

## References

- [MediaPipe LLM Inference Docs](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference?authuser=1)
- [Google AI Edge GitHub Repo](https://github.com/google-ai-edge/mediapipe-samples/tree/main/examples/llm_inference/)
