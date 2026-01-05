class WeatherEntity {
  final String condition; // ví dụ: "Rain", "Clear", "Clouds"
  final bool isDay;
  final double temperature;
  final String cityName;

  WeatherEntity({
    required this.condition,
    required this.isDay,
    required this.temperature,
    required this.cityName,
  });
}
