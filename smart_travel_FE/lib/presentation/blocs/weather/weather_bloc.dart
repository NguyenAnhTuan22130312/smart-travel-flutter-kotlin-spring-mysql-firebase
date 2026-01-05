import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/usecases/destination/get_weather_use_case.dart';
import 'package:smart_travel/presentation/blocs/weather/weather_event.dart';
import 'package:smart_travel/presentation/blocs/weather/weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState>{
  final GetWeatherUseCase getWeatherUseCase;

  WeatherBloc({required this.getWeatherUseCase}) : super(GetWeatherInit()){
    on<GetWeatherEvent>(_onGetWeatherEvent);
  }

  FutureOr<void> _onGetWeatherEvent(
      GetWeatherEvent event,
      Emitter<WeatherState> emit) async {
    emit(GetWeatherLoading());
    final result = await getWeatherUseCase(event.params);
    result.fold((failure) {
      emit(GetWeatherError(failure.message));
    }, (success) {
      emit(GetWeatherSuccess(success));
    });
  }
}