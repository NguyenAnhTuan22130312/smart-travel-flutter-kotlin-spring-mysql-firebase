class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

  //Auth
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String googleLogin = '/auth/google-login';
  static const String facebookLogin = '/auth/facebook-login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String deleteAccount = '/users/account';
  static const String logout = '/auth/logout';

  //Payment
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
  static const String addDestination = '/destination';
  static const String updateDestination = '/destination/';
  static const String deleteDestination = '/destination/';

  //Province
  static const String provinceAll = '/province/all';
  static const String provinceDetail = '/province/detail/';
  static const String addProvince = '/province';
  static const String deleteProvince = '/province/';
  static const String updateProvince = '/province/';

  // Tour
  static const String tour = '/tours';
  static const String tourDetail = '/tours/';
  //Hotel
  static const String hotel = '/hotels';

  //User Profile
  static const String getProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String changePassword = '/users/change-password';
  static const String getSettings = '/users/settings';
  static const String updateSettings = '/users/settings';
  static const String getLevel = '/users/level';
  static const String updateLevel = '/users/level';

  //Admin User Management
  static const String adminUsers = '/admin/users';
  static const String adminUserUpdate = '/admin/users/';
  static const String adminUserLock = '/admin/users/';
  static const String adminUserUnlock = '/admin/users/';

  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
