import 'package:equatable/equatable.dart';

class FavoritePlace extends Equatable {
  final int id;
  final String image;
  final String category;
  final String name;
  final String location;
  final double rating;
  final String price;

  const FavoritePlace({
    required this.id,
    required this.image,
    required this.category,
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
  });

  factory FavoritePlace.fromJson(Map<String, dynamic> json) {
    return FavoritePlace(
      id: int.tryParse(json['id'].toString()) ?? 0,
      image: json['image']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      price: json['price']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'category': category,
      'name': name,
      'location': location,
      'rating': rating,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [
        id,
        image,
        category,
        name,
        location,
        rating,
        price,
      ];
}
