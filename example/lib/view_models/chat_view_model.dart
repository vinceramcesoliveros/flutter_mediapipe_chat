import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_mediapipe_chat/flutter_mediapipe_chat.dart';
import 'package:flutter_mediapipe_chat_example/models/message.dart';

class ChatViewModel extends ChangeNotifier {
  final FlutterMediapipeChat chatPlugin;
  final List<Message> messages = [];

  bool _isGenerating = false;
  bool _isModelLoading = false;
  String? _modelPath;
  String? _modelName;
  ChatMode? _selectedMode;

  StreamSubscription<String>? _subscription;

  bool get isGenerating => _isGenerating;
  bool get isModelLoading => _isModelLoading;
  String? get modelPath => _modelPath;
  String? get modelName => _modelName;
  ChatMode? get selectedMode => _selectedMode;

  ChatViewModel({required this.chatPlugin});

  void setModelLoading(bool loading) {
    _isModelLoading = loading;
    notifyListeners();
  }

  void setModelPath(String path) {
    _modelPath = path;
    notifyListeners();
  }

  void setModelName(String name) {
    _modelName = name;
    notifyListeners();
  }

  void setSelectedMode(ChatMode? mode) {
    _selectedMode = mode ?? ChatMode.streaming;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> sendMessageSynchronous(String prompt) async {
    if (_isGenerating) return;
    messages.add(Message(text: prompt, sender: Sender.user));
    _isGenerating = true;
    notifyListeners();
    final response = await chatPlugin.generateResponse(prompt);
    messages.add(
      Message(
        text: response ?? "Error retrieving response",
        sender: Sender.model,
      ),
    );
    _isGenerating = false;
    notifyListeners();
  }

  void sendMessageStreaming(String prompt) {
    if (_isGenerating) return;
    messages.add(Message(text: prompt, sender: Sender.user));
    _isGenerating = true;
    notifyListeners();
    _subscription?.cancel();
    _handleStreamingResponse(prompt);
  }

  void _handleStreamingResponse(String prompt) {
    String aggregated = "";
    _subscription = chatPlugin.generateResponseAsync(prompt).listen(
      (partialToken) {
        aggregated += partialToken;
        if (messages.isNotEmpty && messages.last.sender == Sender.model) {
          messages[messages.length - 1] =
              Message(text: aggregated, sender: Sender.model);
        } else {
          messages.add(Message(text: aggregated, sender: Sender.model));
        }
        notifyListeners();
      },
      onDone: () {
        _isGenerating = false;
        notifyListeners();
      },
      onError: (_) {
        _isGenerating = false;
        notifyListeners();
      },
    );
  }
}
