import 'package:flutter/material.dart';

class AuthRedirectButton extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback? onPressed;
  final bool enabled;

  const AuthRedirectButton({
    super.key,
    required this.text,
    required this.actionText,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
          children: [
            TextSpan(text: '$text '),
            TextSpan(
              text: actionText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
