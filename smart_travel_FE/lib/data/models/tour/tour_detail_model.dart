import 'package:smart_travel/domain/entities/tour.dart';

class TourDetailModel {
  final int id;
  final String name;
  final String? description;
  final int durationDays;
  final int durationNights;
  final double pricePerPerson;
  final int maxPeople;
  final int minPeople;
  final int destinationId;
  final String? destinationName;
  final List<String> imageUrls;
  final Map<String, dynamic>? included;
  final Map<String, dynamic>? excluded;
  final List<TourScheduleModel> schedules;

  TourDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.durationNights,
    required this.pricePerPerson,
    required this.maxPeople,
    required this.minPeople,
    required this.destinationId,
    required this.destinationName,
    required this.imageUrls,
    required this.included,
    required this.excluded,
    required this.schedules,
  });

  factory TourDetailModel.fromJson(Map<String, dynamic> json) {
    return TourDetailModel(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      durationDays: json["durationDays"],
      durationNights: json["durationNights"],
      pricePerPerson: (json["pricePerPerson"] ?? 0).toDouble(),
      maxPeople: json["maxPeople"],
      minPeople: json["minPeople"],
      destinationId: json["destinationId"],
      destinationName: json["destinationName"],
      imageUrls: List<String>.from(json["images"] ?? []),
      included: json["included"],
      excluded: json["excluded"],
      schedules: (json["schedules"] as List?)
          ?.map((e) => TourScheduleModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class TourScheduleModel {
  final int day;
  final String title;
  final String? activities;
  final String? meals;

  TourScheduleModel({
    required this.day,
    required this.title,
    this.activities,
    this.meals,
  });

  factory TourScheduleModel.fromJson(Map<String, dynamic> json) =>
      TourScheduleModel(
        day: json["dayNumber"],
        title: json["title"],
        activities: json["activities"],
        meals: json["meals"],
      );
}
