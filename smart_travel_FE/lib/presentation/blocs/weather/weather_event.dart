import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/params/get_weather_params.dart';

abstract class WeatherEvent extends Equatable{

}
class GetWeatherEvent extends WeatherEvent{
  final GetWeatherParams params;
  GetWeatherEvent(this.params);
  @override
  List<Object?> get props => [params];
}