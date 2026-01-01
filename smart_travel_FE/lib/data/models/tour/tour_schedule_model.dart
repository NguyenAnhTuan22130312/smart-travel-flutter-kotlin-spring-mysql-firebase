import 'package:smart_travel/domain/entities/tour_schedule.dart'; // Đảm bảo import Entity chính xác

class TourScheduleModel {
  final int id;
  final int dayNumber;
  final String title;
  final String activities;
  final String? accommodation;
  final String meals;

  TourScheduleModel({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.activities,
    this.accommodation,
    required this.meals,
  });

  factory TourScheduleModel.fromJson(Map<String, dynamic> json) {
    return TourScheduleModel(
      id: json['id'] ?? 0,
      dayNumber: json['dayNumber'] ?? 0,
      title: json['title'] ?? "",
      activities: json['activities'] ?? "",
      accommodation: json['accommodation'],
      meals: json['meals'] ?? "",
    );
  }

  TourSchedule toEntity() {
    return TourSchedule(
      id: id,
      dayNumber: dayNumber,
      title: title,
      activities: activities,
      accommodation: accommodation,
      meals: meals,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "dayNumber": dayNumber,
      "title": title,
      "accommodation": accommodation,
      "activities": activities,
    };
  }

}