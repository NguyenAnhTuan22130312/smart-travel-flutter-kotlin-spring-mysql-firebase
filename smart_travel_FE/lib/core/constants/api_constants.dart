class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

  //Auth
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google-login';
  static const String facebookLogin = '/auth/facebook-login';
  static const String forgotPassword = '/auth/forgot-password';


  //Destination
  static const String destinationFeatured = '/destination/destination-featured';
  static const String destinationAll = '/destination/destination-all';
  static const String destinationFilter = '/destination/destination-filter';

  //Province
  static const String provinceAll = '/province/all';
  static const String provinceDetail = '/province/detail/';


  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
