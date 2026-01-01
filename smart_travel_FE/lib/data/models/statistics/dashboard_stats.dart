class TopDestination {
  final int id;
  final String name;
  final int viewCount;
  final String provinceName;

  TopDestination({
    required this.id,
    required this.name,
    required this.viewCount,
    required this.provinceName,
  });

  factory TopDestination.fromJson(Map<String, dynamic> json) {
    return TopDestination(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      provinceName: json['provinceName'] ?? 'N/A',
    );
  }
}

class DashboardStats {
  final int totalUsers;
  final int totalProvinces;
  final int totalDestinations;
  final int totalHotels;
  final int totalTours;
  final List<TopDestination> topDestinations;

  DashboardStats({
    required this.totalUsers,
    required this.totalProvinces,
    required this.totalDestinations,
    required this.totalHotels,
    required this.totalTours,
    required this.topDestinations,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    var topDestList = json['topDestinations'] as List? ?? [];
    List<TopDestination> destinations =
        topDestList
            .map(
              (item) => TopDestination.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalProvinces: json['totalProvinces'] ?? 0,
      totalDestinations: json['totalDestinations'] ?? 0,
      totalHotels: json['totalHotels'] ?? 0,
      totalTours: json['totalTours'] ?? 0,
      topDestinations: destinations,
    );
  }

  // Computed property for total entities
  int get totalEntities =>
      totalProvinces + totalDestinations + totalHotels + totalTours;
}
