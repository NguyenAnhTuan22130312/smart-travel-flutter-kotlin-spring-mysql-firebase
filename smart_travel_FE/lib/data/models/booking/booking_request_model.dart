class BookingRequestModel {
  final String bookingType; // "TOUR" | "HOTEL"
  final int? tourId;        // Có thể null
  final int? hotelId;       // Có thể null
  final String startDate;   // String dạng yyyy-MM-dd
  final String? endDate;    // String dạng yyyy-MM-dd
  final int numberOfPeople;
  final int numberOfRooms;
  final String? couponCode;
  final int? roomTypeId;

  BookingRequestModel({
    required this.bookingType,
    this.tourId,
    this.hotelId,
    required this.startDate,
    this.endDate,
    required this.numberOfPeople,
    required this.numberOfRooms,
    this.couponCode,
    this.roomTypeId,
  });

  // Hàm này dùng để chuyển object thành JSON gửi lên Server
  Map<String, dynamic> toJson() {
    return {
      "bookingType": bookingType,
      "tourId": tourId,
      "hotelId": hotelId,
      "startDate": startDate,
      "endDate": endDate,
      "numberOfPeople": numberOfPeople,
      "numberOfRooms": numberOfRooms,
      "couponCode": couponCode,
      'roomTypeId': roomTypeId,
    };
  }
}