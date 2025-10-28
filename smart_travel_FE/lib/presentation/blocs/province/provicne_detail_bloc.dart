import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/usecases/province/province_detail_use_case.dart';
import 'package:smart_travel/presentation/blocs/province/province_detail_event.dart';
import 'package:smart_travel/presentation/blocs/province/province_detail_state.dart';

class ProvinceDetailBloc extends Bloc<ProvinceDetailEvent, ProvinceDetailState>{
  
  final ProvinceDetailUseCase provinceDetailUseCase;

  ProvinceDetailBloc({required this.provinceDetailUseCase}) : super(ProvinceDetailLoading()){
    on<LoadProvinceDetail>(_onLoadProvinceDetail);
  }

  // Xử lý event LoadProvinceDetail
  Future<void> _onLoadProvinceDetail(
      LoadProvinceDetail event,
      Emitter<ProvinceDetailState> emit)
  async {
    emit(ProvinceDetailLoading());

      final result =
      await provinceDetailUseCase(event.provinceId);

      result.fold(
          (failure) => emit(ProvinceDetailError(failure.message)),
          (province) => emit(ProvinceDetailLoaded(province))
           );
  }
}