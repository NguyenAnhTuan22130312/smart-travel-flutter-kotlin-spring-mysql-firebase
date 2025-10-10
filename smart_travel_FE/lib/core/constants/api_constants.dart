class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

  //Auth
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';

  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
