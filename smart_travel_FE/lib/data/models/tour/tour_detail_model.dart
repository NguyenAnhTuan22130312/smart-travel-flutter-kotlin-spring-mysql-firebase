import 'dart:convert';

import 'package:smart_travel/domain/entities/tour_detail.dart';
import 'tour_image_model.dart';
import 'tour_schedule_model.dart';

class TourDetailModel {
  final int id;
  final String name;
  final String description;
  final int durationDays;
  final int durationNights;
  final double pricePerPerson;
  final double averageRating;
  final List<TourImageModel> images;
  final List<TourScheduleModel> schedules;
  final List<String> included;
  final List<String> excluded;

  List<String> get imageUrls =>
      images
          .map((e) => e.imageUrl)
          .where((url) => url.isNotEmpty) // <<< Lọc rỗng
          .toList();

  TourDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.durationNights,
    required this.pricePerPerson,
    required this.averageRating,
    required this.images,
    required this.schedules,
    required this.included,
    required this.excluded,
  });

  // Hàm helper để parse chuỗi JSON sang List<String> an toàn
  static List<String> _parseJsonList(dynamic jsonValue) {
    if (jsonValue == null) return [];
    if (jsonValue is List) return jsonValue.map((e) => e.toString()).toList();
    if (jsonValue is String) {
      try {
        final decoded = jsonDecode(jsonValue);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {
        return [jsonValue];
      }
    }
    return [];
  }

  factory TourDetailModel.fromJson(Map<String, dynamic> json) =>
      TourDetailModel(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        description: json["description"] ?? "",
        durationDays: json["durationDays"] ?? 0,
        durationNights: json["durationNights"] ?? 0,
        pricePerPerson: (json["pricePerPerson"] ?? 0).toDouble(),
        averageRating: (json["averageRating"] ?? 0).toDouble(),
        included: _parseJsonList(json["included"]),
        excluded: _parseJsonList(json["excluded"]),
        images: (json["images"] as List? ?? [])
            .map((e) => TourImageModel.fromJson(e))
            .where((img) => img.imageUrl.isNotEmpty) // <<< Lọc rỗng/null
            .toList(),
        schedules: (json["schedules"] as List? ?? [])
            .map((e) => TourScheduleModel.fromJson(e))
            .toList(),
      );

  TourDetailModel copyWith({
    List<TourImageModel>? images,
    List<TourScheduleModel>? schedules,
    List<String>? included,
    List<String>? excluded,
  }) {
    return TourDetailModel(
      id: id,
      name: name,
      description: description,
      durationDays: durationDays,
      durationNights: durationNights,
      pricePerPerson: pricePerPerson,
      averageRating: averageRating,
      images: images ?? this.images,
      schedules: schedules ?? this.schedules,
      included: included ?? this.included,
      excluded: excluded ?? this.excluded,
    );
  }

  TourDetail toEntity() => TourDetail(
    id: id,
    name: name,
    description: description,
    durationDays: durationDays,
    durationNights: durationNights,
    pricePerPerson: pricePerPerson,
    averageRating: averageRating,
    images: images.map((e) => e.toEntity()).toList(),
    schedules: schedules.map((e) => e.toEntity()).toList(),
    included: included,
    excluded: excluded,
  );
}
