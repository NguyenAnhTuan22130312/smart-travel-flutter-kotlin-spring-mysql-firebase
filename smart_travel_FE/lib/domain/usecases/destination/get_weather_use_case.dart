import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/weather.dart';
import 'package:smart_travel/domain/params/get_weather_params.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';


class GetWeatherUseCase extends UseCase<WeatherEntity, GetWeatherParams>{
  final DestinationRepository destinationRepository;

  GetWeatherUseCase(this.destinationRepository);

  @override
  Future<Either<Failure, WeatherEntity>> call(GetWeatherParams params) {
   return destinationRepository.weather(params);
  }

}