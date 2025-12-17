import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/usecases/destination/get_detail_destination_use_case.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_detail_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_detail_state.dart';

class DestinationDetailBloc extends Bloc<DestinationDetailEvent, DestinationDetailState>{

  final GetDetailDestinationUseCase getDetailDestinationUseCase;

  DestinationDetailBloc({required this.getDetailDestinationUseCase}) : super(DestinationDetailLoading()){
    on<GetDetailDestinationEvent>(_onGetDetailDestinationEvent);
  }

  ///Xem chi tiết địa điểm
  Future<void> _onGetDetailDestinationEvent(
      GetDetailDestinationEvent event,
      Emitter<DestinationDetailState> emit) async{
    emit(DestinationDetailLoading());
    final result = await getDetailDestinationUseCase(event.id);
    result.fold(
            (failure)=> emit(DestinationDetailError(failure.message)),
            (destinationDetail)=> emit(DestinationDetailLoaded(destinationDetail))
    );
  }

}