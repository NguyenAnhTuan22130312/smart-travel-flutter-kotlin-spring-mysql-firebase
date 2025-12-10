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
  final Map<String, dynamic> included;
  final Map<String, dynamic> excluded;

  List<String> get imageUrls =>
      images.map((e) => e.imageUrl).toList();

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

  factory TourDetailModel.fromJson(Map<String, dynamic> json) =>
      TourDetailModel(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        description: json["description"] ?? "",
        durationDays: json["durationDays"] ?? 0,
        durationNights: json["durationNights"] ?? 0,
        pricePerPerson: (json["pricePerPerson"] ?? 0).toDouble(),
        averageRating: (json["averageRating"] ?? 0).toDouble(),
        included: json["included"] ?? {},
        excluded: json["excluded"] ?? {},

        images: (json["images"] as List? ?? [])
            .map((e) => TourImageModel.fromJson(e))
            .toList(),

        schedules: (json["schedules"] as List? ?? [])
            .map((e) => TourScheduleModel.fromJson(e))
            .toList(),
      );

  TourDetailModel copyWith({
    List<TourImageModel>? images,
    List<TourScheduleModel>? schedules,
    Map<String, dynamic>? included,
    Map<String, dynamic>? excluded,
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
