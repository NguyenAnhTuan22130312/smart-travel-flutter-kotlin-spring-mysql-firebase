class HotelCreateRequest {
  final String name;
  final String address;
  final int stars;
  final String description;
  final double latitude;
  final double longitude;
  final int destinationId;
  final String phone;
  final String email;
  final List<String> amenities;
  final int totalRooms;
  final int availableRooms;
  final String thumbnail;
  final List<String> images;
  final List<RoomTypeCreateRequest> roomTypes;

  HotelCreateRequest({
    required this.name,
    required this.address,
    required this.stars,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.destinationId,
    required this.phone,
    required this.email,
    required this.amenities,
    required this.totalRooms,
    required this.availableRooms,
    required this.thumbnail,
    required this.images,
    required this.roomTypes,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "address": address,
      "stars": stars,
      "description": description,
      "latitude": latitude,
      "longitude": longitude,
      "destinationId": destinationId,
      "phone": phone,
      "email": email,
      "amenities": amenities,
      "totalRooms": totalRooms,
      "availableRooms": availableRooms,
      "thumbnail": thumbnail,
      "images": images,
      "roomTypes": roomTypes.map((e) => e.toJson()).toList(),
    };
  }
}

class RoomTypeCreateRequest {
  final String name;
  final int capacity;
  final double price;
  final int totalRooms;
  final List<String> amenities;

  RoomTypeCreateRequest({
    required this.name,
    required this.capacity,
    required this.price,
    required this.totalRooms,
    required this.amenities,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "capacity": capacity,
      "price": price,
      "totalRooms": totalRooms,
      "amenities": amenities,
    };
  }
}
