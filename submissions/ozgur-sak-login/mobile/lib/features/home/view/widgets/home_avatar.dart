import 'package:flutter/material.dart';

class HomeAvatar extends StatelessWidget {
  final double size;

  const HomeAvatar({
    super.key,
    this.size = 84.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0F382C), // Circular dark green icon
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 3.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_rounded,
        color: Colors.white, // White user profile silhouette
        size: 48,
      ),
    );
  }
}
