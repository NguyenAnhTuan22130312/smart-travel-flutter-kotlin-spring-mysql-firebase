import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/weather.dart';

abstract class WeatherState extends Equatable{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
class GetWeatherInit extends WeatherState{}

//Lấy thông tin thời tiết
class GetWeatherLoading extends WeatherState{}
class GetWeatherSuccess extends WeatherState{
  final WeatherEntity entity;
  GetWeatherSuccess(this.entity);
}
class GetWeatherError extends WeatherState{
  final String message;
  GetWeatherError(this.message);
}