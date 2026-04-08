class ApiConstants {
  //static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
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
  static const String completeVoice = '/destination/';

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

  //Admin Statistics
  static const String adminStatistics = '/admin/statistics/dashboard';
  
  // Admin Tour 
  static const String adminTours = '/admin/tours';
  static const String adminTourDetail = '/admin/tours/';
  static const String adminTourImages = '/admin/tours/images/';
  static const String adminTourSchedules = '/admin/tours/schedules/';

  // Invoice
  static const String invoiceActive = '/invoices/active';
  static const String invoiceRefunded = '/invoices/refunded';
  static const String invoiceReviewable = '/invoices/reviewable';
  static const String invoiceDetail = '/invoices/detail/';
  static const String invoiceActiveSearch = '/invoices/active/search';
  static const String invoiceRefundedSearch = '/invoices/refunded/search';
  static const String invoiceHistory = '/invoices/history';
  static const String invoiceRefund = '/invoices/refund';

  static const String adminGetInvoice = '/invoices/admin-get-invoices';
  static const String adminGetDetailInvoice = '/invoices/admin-get-detail-invoice/';
  static const String adminApproveRefund = '/invoices/admin/approve-refund';
  static const String adminCheckIn = '/invoices/admin/check-in';
  static const String adminCheckOut = '/invoices/admin/check-out';
  static const String adminCancelOrder = '/invoices/admin/cancel-order';


  //Banner
  static const String getAllBanner = '/banners';
  static const String updateBanner = '/banners/';
  static const String createBanner = '/banners/banner';
  static const String deleteBanner = '/banners/';

  //Review
  static const String invoiceReview = '/reviews/invoice-review';
  static const String destinationReview = '/reviews/destination-review';
  static const String tourReview = '/reviews/tour/';
  static const String hotelReview = '/reviews/hotel/';
  static const String desReview = '/reviews/destination/';
  static const String allReview = '/reviews/get-reviews';

  //voucher
  static const String getAllVoucher = '/admin/vouchers';
  static const String createVoucher = '/admin/vouchers';
  static const String updateVoucher = '/admin/vouchers/';
  static const String deleteVoucher = '/admin/vouchers/';

  //Weather
  static const String weather = 'https://api.openweathermap.org/data/2.5/';


  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
