import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mediapipe_chat/flutter_mediapipe_chat.dart';
import 'package:flutter_mediapipe_chat/models/model_config.dart';

void main() {
  runApp(const MyApp());
}

class MessageData {
  final String message;
  final String sender;
  MessageData({required this.message, required this.sender});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterMediapipeChat chat = FlutterMediapipeChat();
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<MessageData> messages = [];
  String? modelPath;
  bool isGenerating = false;
  bool isModelLoading = false;
  StreamSubscription<String>? chatSubscription;

  @override
  void dispose() {
    chatSubscription?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickModel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        modelPath = result.files.single.path;
        isModelLoading = true;
      });
      ModelConfig config = ModelConfig(
        path: modelPath!,
        temperature: 0.8,
        maxTokens: 1024,
        topK: 40,
        randomSeed: 1,
      );
      await chat.loadModel(config);
      setState(() {
        isModelLoading = false;
      });
    }
  }

  void _sendMessage({bool useStreaming = true}) async {
    if (textController.text.isEmpty || isModelLoading || isGenerating) return;
    setState(() {
      messages.add(MessageData(message: textController.text, sender: "user"));
      isGenerating = true;
    });
    final prompt = textController.text;
    textController.clear();
    _scrollToBottom();
    if (useStreaming) {
      _startStreamingResponse(prompt);
    } else {
      _startAsyncResponse(prompt);
    }
  }

  void _startStreamingResponse(String prompt) {
    chatSubscription?.cancel();
    chatSubscription = chat.generateResponseStream(prompt).listen((response) {
      if (response.isNotEmpty) {
        setState(() {
          messages.add(MessageData(message: response, sender: "model"));
        });
        _scrollToBottom();
      }
    }, onDone: () {
      setState(() {
        isGenerating = false;
      });
    }, onError: (_) {
      setState(() {
        isGenerating = false;
      });
    });
  }

  void _startAsyncResponse(String prompt) async {
    final response = await chat.generateResponse(prompt);
    setState(() {
      messages.add(MessageData(
          message: response ?? "Error en la respuesta", sender: "model"));
      isGenerating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Flutter Mediapipe Chat"),
          actions: [
            IconButton(
                icon: const Icon(Icons.folder_open), onPressed: _pickModel),
          ],
        ),
        body: isModelLoading
            ? const Center(child: LoadingAnimation())
            : modelPath == null
                ? _initialScreen()
                : _chatScreen(),
      ),
    );
  }

  Widget _initialScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.file_open, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          const Text("Selecciona un modelo para comenzar",
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: _pickModel, child: const Text("Cargar Modelo")),
        ],
      ),
    );
  }

  Widget _chatScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Modelo: ${modelPath!.split('/').last}",
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return ChatBubble(messageData: msg);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: "Escribe un mensaje...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24)),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (isGenerating)
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.stream, color: Colors.green),
                      onPressed: () => _sendMessage(useStreaming: true),
                      tooltip: "Usar Streaming",
                    ),
                    IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.blue),
                      onPressed: () => _sendMessage(useStreaming: false),
                      tooltip: "Usar Async",
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final MessageData messageData;
  const ChatBubble({super.key, required this.messageData});

  @override
  Widget build(BuildContext context) {
    final isUser = messageData.sender == "user";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey,
                child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[300] : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                messageData.message,
                style: TextStyle(color: isUser ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});
  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}
