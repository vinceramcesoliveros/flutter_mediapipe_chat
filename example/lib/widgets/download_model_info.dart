import 'package:flutter/material.dart';

class DownloadModelInfo extends StatelessWidget {
  const DownloadModelInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final styles = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Don't have a model yet?",
          style: styles.titleSmall?.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'You can download CPU or GPU models from Kaggle:\n\n'
          'https://www.kaggle.com/models/google/gemma/tfLite\n'
          'https://www.kaggle.com/models/google/gemma-2/tfLite',
          style: styles.bodyMedium?.copyWith(color: colors.onSurface),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
