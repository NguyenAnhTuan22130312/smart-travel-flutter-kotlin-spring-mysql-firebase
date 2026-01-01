import 'tour_image.dart';
import 'tour_schedule.dart';

class TourDetail {
  final int id;
  final String name;
  final String description;
  final int durationDays;
  final int durationNights;
  final double pricePerPerson;
  final double averageRating;
  final List<TourImage> images;
  final List<TourSchedule> schedules;
  final List<String> included;
  final List<String> excluded;

  List<String> get imageUrls => images.map((e) => e.imageUrl).toList();

  TourDetail({
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
}
