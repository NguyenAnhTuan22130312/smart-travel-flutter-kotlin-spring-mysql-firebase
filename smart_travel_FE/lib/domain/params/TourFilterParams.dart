class TourFilterParams {
  final String? keyword;
  final int? minPrice;
  final int? maxPrice;
  final int? minDays;
  final int? maxDays;
  final int? minPeople;
  final double? minRating;
  final String? sort;
  final int page;
  final int size;

  TourFilterParams({
    this.keyword,
    this.minPrice,
    this.maxPrice,
    this.minDays,
    this.maxDays,
    this.minPeople,
    this.minRating,
    this.sort,
    this.page = 0,
    this.size = 10,
  });

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };

    if (keyword != null && keyword!.isNotEmpty) params['keyword'] = keyword!;
    if (minPrice != null) params['minPrice'] = minPrice.toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
    if (minDays != null) params['minDays'] = minDays.toString();
    if (maxDays != null) params['maxDays'] = maxDays.toString();
    if (minRating != null) params['minRating'] = minRating.toString();
    if (sort != null) params['sort'] = sort!;

    return params;
  }

  factory TourFilterParams.fromMap(Map<String, dynamic> map) {
    return TourFilterParams(
      keyword: map["keyword"],
      minPrice: map["minPrice"],
      maxPrice: map["maxPrice"],
      minDays: map["minDays"],
      maxDays: map["maxDays"],
      minPeople: map["minPeople"],
      minRating: map["minRating"] != null
          ? double.tryParse(map["minRating"].toString())
          : null,
      sort: map["sort"],
      page: map["page"] ?? 0,
      size: map["size"] ?? 10,
    );
  }
}
