class RoomType {
  final int id;
  final String name;
  final int? capacity;        // Sức chứa tối đa
  final double? price;        // Giá / đêm
  final int? availableRooms;  // Số phòng trống (nếu có)
  final List<String>? amenities; // ["WiFi", "Breakfast"]

  RoomType({
    required this.id,
    required this.name,
    this.capacity,
    this.price,
    this.availableRooms,
    this.amenities,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      id: json['id'],
      name: json['name'],
      capacity: json['capacity'],
      price: (json['price'] != null)
          ? (json['price'] is int ? (json['price'] as int).toDouble() : json['price'])
          : null,
      availableRooms: json['availableRooms'],
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'price': price,
      'availableRooms': availableRooms,
      'amenities': amenities,
    };
  }
}
