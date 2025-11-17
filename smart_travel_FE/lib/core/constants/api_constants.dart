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

  static const String createOnlinePayment = '/payment/create-online-payment';
  static const String confirmCashPayment = '/payment/confirm-cash-payment';
  static const String vnpayReturn = '/payment/vnpay-return';
  static const String momoReturn = '/payment/momo-return';
  static const String createBooking = '/bookings';

  //Destination
  static const String destinationFeatured = '/destination/destination-featured';
  static const String destinationAll = '/destination/destination-all';
  static const String destinationFilter = '/destination/destination-filter';
  static const String destinationDetail = '/destination/detail/';

  //Province
  static const String provinceAll = '/province/all';
  static const String provinceDetail = '/province/detail/';


  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
