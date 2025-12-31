class UpdateTourRequestModel {
  final String name;
  final String? description;
  final double pricePerPerson;
  final int durationDays;
  final int durationNights;
  final int minPeople;
  final int maxPeople;
  final bool isActive;
  final List<Map<String, dynamic>> images;
  final List<Map<String, dynamic>> schedules;
  final List<String> included;
  final List<String> excluded;

  UpdateTourRequestModel({
    required this.name,
    this.description,
    required this.pricePerPerson,
    required this.durationDays,
    required this.durationNights,
    required this.minPeople,
    required this.maxPeople,
    required this.isActive,
    required this.images,
    required this.schedules,
    required this.included,
    required this.excluded,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "pricePerPerson": pricePerPerson,
      "durationDays": durationDays,
      "durationNights": durationNights,
      "minPeople": minPeople,
      "maxPeople": maxPeople,
      "isActive": isActive,
      "images": images,
      "schedules": schedules,
      "included": included,
      "excluded": excluded,
    };
  }
}
