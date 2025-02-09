import 'package:flutter/material.dart';

class CustomLoading extends StatelessWidget {
  final Alignment alignment;
  const CustomLoading({
    super.key,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: CircularProgressIndicator.adaptive(),
    );
  }
}
