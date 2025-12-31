import 'package:flutter/material.dart';

class AppColors {
  // Màu chính (Primary)
  static const Color primary = Color(0xFF2196F3); // Blue

  // Màu phụ (Secondary)
  static const Color green = Color(0xFF38DFBD); // green
  //
  static const Color button = Color(0xFF23A39B); // Orange

  // Màu phụ (Secondary)
  static const Color secondary = Color(0xFFFF9800); // Orange

  static const Color success = Color(0xFF38DFBD);

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
      green,
      button,
    ],
  );

  // Profile colors (based on mockup)
  static const Color profileHeaderBrown = Color(0xFF8B6B47); // Warm brown for header
  static const Color profileBadgeGold = Color(0xFFFFD700); // Gold for VIP badge
  static const Color menuIconGray = Color(0xFF4A5568); // Icons in menu
  static const Color dividerGray = Color(0xFFE2E8F0); // Divider lines
}

