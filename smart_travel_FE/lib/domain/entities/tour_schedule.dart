class TourSchedule {
  final int id;
  final int dayNumber;
  final String title;
  final String activities;
  final String? accommodation;
  final String meals;

  TourSchedule({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.activities,
    this.accommodation,
    required this.meals,
  });
}
