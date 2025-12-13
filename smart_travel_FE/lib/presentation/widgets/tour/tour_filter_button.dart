import 'package:flutter/material.dart';

class TourFilterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TourFilterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(
        Icons.filter_alt_rounded,
        color: Color(0xFF5BEDD2),
        size: 32,
      ),
    );
  }
}
