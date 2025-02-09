import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mediapipe_chat/flutter_mediapipe_chat.dart';
import 'package:flutter_mediapipe_chat_example/models/message.dart';
import 'package:flutter_mediapipe_chat_example/view_models/chat_view_model.dart';
import 'package:flutter_mediapipe_chat_example/widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late final FlutterMediapipeChat chatPlugin;
  late final ChatViewModel viewModel;
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    chatPlugin = FlutterMediapipeChat();
    viewModel = ChatViewModel(chatPlugin: chatPlugin);
    _controller = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickModel() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path!;
      final name = result.files.single.name;
      viewModel.setModelLoading(true);
      viewModel.setModelPath(path);
      viewModel.setModelName(name);

      final config = ModelConfig(
        path: path,
        temperature: 0.8,
        maxTokens: 1024,
        topK: 40,
        randomSeed: 1,
      );
      await chatPlugin.loadModel(config);
      viewModel.setModelLoading(false);
      _askForMode();
    }
  }

  Future<void> _askForMode() async {
    final mode = await showDialog<ChatMode>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        final styles = Theme.of(dialogContext).textTheme;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            'Select Chat Mode',
            style: styles.titleMedium?.copyWith(color: colors.onSurface),
          ),
          content: Text(
            'Do you want to use Synchronous (blocking) or Streaming mode?',
            style: styles.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ChatMode.synchronous),
              child: Text(
                'Synchronous',
                style: styles.labelLarge?.copyWith(color: colors.primary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ChatMode.streaming),
              child: Text(
                'Streaming',
                style: styles.labelLarge?.copyWith(color: colors.primary),
              ),
            ),
          ],
        );
      },
    );
    viewModel.setSelectedMode(mode);
  }

  void _sendMessage() {
    if (_controller.text.isEmpty || viewModel.selectedMode == null) return;
    final prompt = _controller.text;
    _controller.clear();
    if (viewModel.selectedMode == ChatMode.synchronous) {
      viewModel.sendMessageSynchronous(prompt);
      return;
    }
    viewModel.sendMessageStreaming(prompt);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final styles = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        Widget bodyContent = const SizedBox();
        if (viewModel.isModelLoading) {
          bodyContent = const CustomLoading();
        }
        if (!viewModel.isModelLoading && viewModel.modelPath == null) {
          bodyContent = BodyNoModel(pickModel: _pickModel);
        }
        if (!viewModel.isModelLoading && viewModel.modelPath != null) {
          bodyContent = BodyModelLoaded(
            modelName: viewModel.modelName,
            selectedMode: viewModel.selectedMode,
            viewModel: viewModel,
            scrollController: _scrollController,
            controller: _controller,
            sendMessage: _sendMessage,
            scrollToBottom: _scrollToBottom,
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Local AI Chat",
              style: styles.titleLarge?.copyWith(color: colors.onSurface),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.folder_open, color: colors.onSurface),
                onPressed: _pickModel,
              ),
            ],
          ),
          body: bodyContent,
        );
      },
    );
  }
}

class EmptyChatPlaceholder extends StatelessWidget {
  const EmptyChatPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Icon(
        Icons.chat_bubble_outline,
        size: 100,
        color: colors.outline,
      ),
    );
  }
}

class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: CircularProgressIndicator(color: colors.primary),
    );
  }
}

class BodyNoModel extends StatelessWidget {
  final VoidCallback pickModel;
  const BodyNoModel({super.key, required this.pickModel});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final styles = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.file_open, size: 80, color: colors.onSurface),
          const SizedBox(height: 20),
          Text(
            "Select an AI model to get started",
            style: styles.titleMedium?.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: pickModel,
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
            child: Text(
              "Load Model",
              style: styles.labelLarge?.copyWith(color: colors.onPrimary),
            ),
          ),
          IconButton(
            icon: Icon(Icons.cloud_download_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog.adaptive(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    content: const DownloadModelInfo(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class BodyModelLoaded extends StatelessWidget {
  final String? modelName;
  final ChatMode? selectedMode;
  final ChatViewModel viewModel;
  final ScrollController scrollController;
  final TextEditingController controller;
  final VoidCallback sendMessage;
  final VoidCallback scrollToBottom;

  const BodyModelLoaded({
    super.key,
    required this.modelName,
    required this.selectedMode,
    required this.viewModel,
    required this.scrollController,
    required this.controller,
    required this.sendMessage,
    required this.scrollToBottom,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final styles = Theme.of(context).textTheme;
    return Column(
      children: [
        if (modelName != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              "Model loaded: $modelName",
              style: styles.titleMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        if (selectedMode != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Selected mode: "
              "${selectedMode == ChatMode.synchronous ? "Synchronous (blocking)" : "Streaming"}",
              style: styles.labelMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        Expanded(
          child: AnimatedBuilder(
            animation: viewModel,
            builder: (context, _) {
              scrollToBottom();
              if (viewModel.messages.isEmpty) {
                return const EmptyChatPlaceholder();
              }
              return ListView.builder(
                controller: scrollController,
                itemCount: viewModel.messages.length,
                itemBuilder: (context, index) {
                  final message = viewModel.messages[index];
                  final useTypewriter = message.sender == Sender.model &&
                      viewModel.isGenerating &&
                      index == viewModel.messages.length - 1 &&
                      selectedMode == ChatMode.streaming;
                  return ChatBubble(
                    message: message,
                    useTypewriter: useTypewriter,
                  );
                },
              );
            },
          ),
        ),
        ChatInput(
          controller: controller,
          isGenerating: viewModel.isGenerating,
          onSend: sendMessage,
        ),
      ],
    );
  }
}
