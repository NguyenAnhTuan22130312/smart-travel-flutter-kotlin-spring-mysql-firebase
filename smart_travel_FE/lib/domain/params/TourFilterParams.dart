class TourFilterParams {
  final int page;
  final int size;
  final int? minDays;
  final int? maxDays;
  final double? minPrice;
  final double? maxPrice;
  final int? numberOfPeople;
  final int? destinationId;

  TourFilterParams({
    this.page = 0,
    this.size = 10,
    this.minDays,
    this.maxDays,
    this.minPrice,
    this.maxPrice,
    this.numberOfPeople,
    this.destinationId,
  });
}
