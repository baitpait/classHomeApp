import 'package:flutter/material.dart';

class AppBackButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;

  const AppBackButtonWidget({
    super.key,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(Icons.arrow_back_ios_new, size: 20, color: color),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }
}

