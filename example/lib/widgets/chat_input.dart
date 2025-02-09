import 'package:flutter/material.dart';

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
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              style: styles.bodyMedium?.copyWith(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Write a message...",
                hintStyle: styles.labelMedium?.copyWith(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          if (isGenerating)
            CircularProgressIndicator.adaptive()
          else
            InkWell(
              onTap: onSend,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.onSurface,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.arrow_upward, color: colors.surface),
              ),
            ),
        ],
      ),
    );
  }
}
