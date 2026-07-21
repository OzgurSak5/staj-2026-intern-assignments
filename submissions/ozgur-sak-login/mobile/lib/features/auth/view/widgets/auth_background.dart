import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image from assets
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_auth.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFE5E5), Color(0xFFE53935)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
          ),
          // Dark overlay for glassmorphism contrast
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.15)),
          ),
          // Main content on top
          SafeArea(child: child),
        ],
      ),
    );
  }
}
