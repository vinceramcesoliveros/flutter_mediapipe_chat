import 'package:flutter/material.dart';
import 'package:flutter_mediapipe_chat_example/widgets/custom_loading.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isGenerating;
  final VoidCallback onSend;

  const ChatInput({
    super.key,
    required this.controller,
    required this.isGenerating,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final styles = Theme.of(context).textTheme;
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: styles.bodyMedium?.copyWith(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Write a message...",
                hintStyle: styles.labelMedium?.copyWith(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                suffixIcon: isGenerating
                    ? const CustomLoading()
                    : IconButton(
                        onPressed: onSend,
                        icon: Icon(Icons.send, color: colors.primary),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
