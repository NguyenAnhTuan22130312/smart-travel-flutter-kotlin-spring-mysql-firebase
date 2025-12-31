import 'dart:convert';

import 'tour_image_model.dart';
import 'tour_schedule_model.dart';

class AdminTourModel {
  final int id;
  final String name;
  final int durationDays;
  final double averageRating;
  final double pricePerPerson;
  final String destinationName;
  final bool isActive;
  final int durationNights;
  final int maxPeople;
  final int minPeople;
  final int destinationId;
  final String? description;
  final int bookingCount;
  final String? image; // lấy ảnh chính đầu tiên nếu JSON là list
  final List<TourScheduleModel> schedules;
  final List<TourImageModel> images;
  final DateTime createdAt;
  final List<String> included;
  final List<String> excluded;

  AdminTourModel({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.averageRating,
    required this.pricePerPerson,
    required this.destinationName,
    required this.isActive,
    required this.maxPeople,
    required this.minPeople,
    required this.description,
    required this.bookingCount,
    required this.schedules,
    required this.createdAt,
    required this.durationNights,
    required this.included,
    required this.excluded,
    this.image,
    required this.destinationId,
    required this.images,
  });

  factory AdminTourModel.fromJson(Map<String, dynamic> json) {
    // Parse maxPeople an toàn
    int parsedMaxPeople = 0;
    if (json['maxPeople'] != null) {
      parsedMaxPeople = (json['maxPeople'] is int)
          ? json['maxPeople']
          : int.tryParse(json['maxPeople'].toString()) ?? 0;
    }

    int parsedMinPeople = 0;
    if (json['minPeople'] != null) {
      parsedMinPeople = (json['minPeople'] is int)
          ? json['minPeople']
          : int.tryParse(json['minPeople'].toString()) ?? 0;
    }

    // Parse image (nếu JSON là list)
    String? parsedImage;
    List<TourImageModel> parseImages = [];

// ===== CASE 1: LIST API → images là STRING
    if (json['images'] is String) {
      parsedImage = json['images'];
    }

// ===== CASE 2: DETAIL API → images là LIST
    else if (json['images'] is List) {
      final list = json['images'] as List;

      parseImages = list
          .where((e) => e is Map<String, dynamic>)
          .map((e) => TourImageModel.fromJson(e))
          .toList();

      if (parseImages.isNotEmpty) {
        final primary = parseImages.firstWhere(
              (e) => e.isPrimary,
          orElse: () => parseImages.first,
        );
        parsedImage = primary.imageUrl;
      }
    }

// ===== FALLBACK (PHÒNG HỜ)
    parsedImage ??= json['image']?.toString();
    parsedImage ??= json['imageUrl']?.toString();


    // Parse schedules an toàn
    List<TourScheduleModel> parsedSchedules = [];
    if (json['schedules'] != null && json['schedules'] is List) {
      parsedSchedules = (json['schedules'] as List)
          .map((e) {
        if (e is Map<String, dynamic>) {
          return TourScheduleModel.fromJson(e);
        }
        return null;
      })
          .whereType<TourScheduleModel>()
          .toList();
    }

    List<String> _parseStringList(dynamic value) {
      if (value == null) return [];

      // Backend trả String JSON
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {
          return [];
        }
      }

      // Backend trả List sẵn
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }

      return [];
    }

    return AdminTourModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      durationDays: json['durationDays'] is int
          ? json['durationDays']
          : int.tryParse(json['durationDays']?.toString() ?? '0') ?? 0,
      averageRating: json['averageRating'] is num
          ? (json['averageRating'] as num).toDouble()
          : double.tryParse(json['averageRating']?.toString() ?? '0') ?? 0,
      pricePerPerson: json['pricePerPerson'] is num
          ? (json['pricePerPerson'] as num).toDouble()
          : double.tryParse(json['pricePerPerson']?.toString() ?? '0') ?? 0,
      destinationName: json['destinationName']?.toString() ?? '',
      isActive: json['isActive'] == true,
      maxPeople: parsedMaxPeople,
      minPeople: parsedMinPeople,
      description: json['description']?.toString(),
      bookingCount: json['bookingCount'] is int
          ? json['bookingCount']
          : int.tryParse(json['bookingCount']?.toString() ?? '0') ?? 0,
      schedules: parsedSchedules,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      image: parsedImage,
      images: parseImages,
      destinationId: json['destinationId'] is int
          ? json['destinationId']
          : int.tryParse(json['destinationId']?.toString() ?? '0') ?? 0,
      included: _parseStringList(json['included']),
      excluded: _parseStringList(json['excluded']),
      durationNights: json['durationNights'] is int
          ? json['durationNights']
          : int.tryParse(json['durationNights']?.toString() ?? '0') ?? 0,
    );
  }
}
