import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/data/models/tour/admin_tour_model.dart';
import 'package:smart_travel/domain/usecases/tour/delete_image_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/delete_tour_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/get_admin_detail_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/set_primary_tour_image_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/update_tour_usecase.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_detail_event.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_detail_state.dart';

class AdminTourDetailBloc
    extends Bloc<AdminTourDetailEvent, AdminTourDetailState> {
  final GetAdminTourDetailUseCase getDetail;
  final UpdateAdminTourUseCase updateTour;
  final SetPrimaryTourImageUseCase setPrimaryImage;
  final DeleteTourImageUseCase deleteAdminTourImage;

  AdminTourDetailBloc(this.getDetail, this.updateTour, this.setPrimaryImage, this.deleteAdminTourImage)
      : super(AdminTourDetailInitial()) {
    on<LoadAdminTourDetail>(_onLoadDetail);
    on<UpdateAdminTourDetail>(_onUpdate);
    on<SetPrimaryAdminTourImage>(_onSetPrimaryImage);
    on<DeleteAdminTourImage>(_onDeleteImage);
  }

  Future<void> _onLoadDetail(
      LoadAdminTourDetail event,
      Emitter<AdminTourDetailState> emit,
      ) async {
    emit(AdminTourDetailLoading());
    try {
      final AdminTourModel tour = await getDetail(event.id);
      emit(AdminTourDetailLoaded(tour));
    } catch (e) {
      emit(AdminTourDetailError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdateAdminTourDetail event,
      Emitter<AdminTourDetailState> emit,
      ) async {
    emit(AdminTourUpdateLoading());

    try {
      await updateTour(event.id, event.body);

      emit(AdminTourUpdateSuccess());

      final updated = await getDetail(event.id);
      emit(AdminTourDetailLoaded(updated));
    } catch (e) {
      emit(AdminTourDetailError(e.toString()));
    }
  }

  Future<void> _onSetPrimaryImage(
      SetPrimaryAdminTourImage event,
      Emitter<AdminTourDetailState> emit,
      ) async {
    emit(AdminTourImageUpdating());
    try {
      await setPrimaryImage(event.imageId);

      emit(AdminTourImageUpdated());

      final updated = await getDetail(event.tourId);
      emit(AdminTourDetailLoaded(updated));
    } catch (e) {
      emit(AdminTourDetailError(e.toString()));
    }
  }

  Future<void> _onDeleteImage(
      DeleteAdminTourImage event,
      Emitter<AdminTourDetailState> emit,
      ) async {
      emit(AdminTourImageUpdating());
    try {
      await deleteAdminTourImage(event.imageId);

      final updated = await getDetail(event.tourId);
      emit(AdminTourImageUpdated());
      emit(AdminTourDetailLoaded(updated));
      print("Deleting imageId=${event.imageId} from tourId=${event.tourId}");
    } catch (e) {
      emit(AdminTourDetailError(e.toString()));
    }
  }

}
