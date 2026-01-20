class BookingArgs {
  final String bookingType;
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final int? roomTypeId;

  BookingArgs({
    required this.bookingType,
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.roomTypeId,
  });
}