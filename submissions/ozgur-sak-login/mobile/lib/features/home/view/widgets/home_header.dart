import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const HomeHeader({
    super.key,
    this.title = 'Hoş Geldiniz',
    this.subtitle = 'Başarıyla giriş yaptınız.',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF263238),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
