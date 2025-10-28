import 'package:flutter/material.dart';

class AppColors {
  // Màu chính (Primary)
  static const Color primary = Color(0xFF2196F3); // Blue

  // Màu phụ (Secondary)
  static const Color green = Color(0xFF5BEDD2); // green

  // Màu phụ (Secondary)
  static const Color secondary = Color(0xFFFF9800); // Orange


  // Accent
  static const Color accent = Color(0xFF4CAF50); // Green

  // Background
  static const Color background = Color(0xFFFFFFFF); // White

  // Text màu trắng
  static const Color textWhite = Color(0xFFFFFFFF); // White
  // Text màu xám
  static const Color textGray = Color(0xFF374151);

  // Gradient dùng nhiều lần
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      accent,
      secondary,
    ],
  );
}
