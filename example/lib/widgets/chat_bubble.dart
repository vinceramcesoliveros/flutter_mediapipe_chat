import 'package:flutter/material.dart';
import 'package:flutter_mediapipe_chat_example/models/message.dart';
import 'package:flutter_mediapipe_chat_example/widgets/typewriter_text.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool useTypewriter;

  const ChatBubble({
    super.key,
    required this.message,
    this.useTypewriter = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final styles = Theme.of(context).textTheme;
    final isUser = message.sender == Sender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? colors.primary : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
        ),
        child: useTypewriter
            ? TypewriterText(
                text: message.text,
                style: styles.bodyMedium
                    ?.copyWith(color: isUser ? colors.onPrimary : Colors.white),
              )
            : Text(
                message.text,
                style: styles.bodyMedium
                    ?.copyWith(color: isUser ? colors.onPrimary : Colors.white),
              ),
      ),
    );
  }
}
