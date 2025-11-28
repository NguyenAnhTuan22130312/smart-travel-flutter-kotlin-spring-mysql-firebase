class TourDetailEntity {
  final int id;
  final String name;
  final String description;
  final int durationDays;
  final int durationNights;
  final double pricePerPerson;
  final double rating;
  final List<TourImageEntity> images;
  final List<TourScheduleEntity> schedules;

  TourDetailEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.durationNights,
    required this.pricePerPerson,
    required this.rating,
    required this.images,
    required this.schedules,
  });
}
