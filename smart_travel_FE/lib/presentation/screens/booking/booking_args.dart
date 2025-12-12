class BookingArgs {
  final String bookingType; // 'TOUR' hoặc 'HOTEL'
  final int id;             // tourId hoặc hotelId
  final String name;        // Tên tour/hotel để hiển thị
  final double price;       // Giá (người hoặc phòng)
  final String imageUrl;    // Ảnh thumbnail

  BookingArgs({
    required this.bookingType,
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}