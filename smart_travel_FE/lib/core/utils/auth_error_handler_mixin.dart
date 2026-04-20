import 'package:flutter/material.dart';

/// Mixin giúp xử lý chung logic điều hướng khi Token hết hạn hoặc gặp lỗi 401 Unauthorized
mixin AuthErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  /// Kiểm tra xem lỗi có phải do token hết hạn không.
  /// Nếu đúng, tự động điều hướng về màn hình đăng nhập và trả về `true`.
  /// Nếu sai, trả về `false`.
  bool handleTokenExpiration(String errorMessage) {
    final lowerMessage = errorMessage.toLowerCase();
    
    if (lowerMessage.contains('unauthorized') ||
        lowerMessage.contains('401') ||
        lowerMessage.contains('phiên đăng nhập hết hạn') ||
        lowerMessage.contains('token')) {
          
      // Xóa tất cả các màn hình trong stack và chuyển hướng về /login
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
      return true;
    }
    
    return false;
  }
}
