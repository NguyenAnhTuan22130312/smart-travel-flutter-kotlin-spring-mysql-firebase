import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/data/models/tour/admin_tour_model.dart';

import 'package:smart_travel/domain/usecases/tour/delete_image_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/set_primary_tour_image_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/upload_image_usecase.dart';
import 'tour_event.dart';
import 'tour_state.dart';
import 'package:smart_travel/domain/usecases/tour/get_admin_tour_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/create_tour_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/delete_tour_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/update_tour_usecase.dart';

class AdminTourBloc extends Bloc<AdminTourEvent, AdminTourState> {
  final GetAdminTours getAdminTours;
  final CreateAdminTourUseCase createAdminTour;
  final DeleteAdminTourUseCase deleteAdminTour;
  final UploadTourImageUseCase uploadTourImage;
  final DeleteTourImageUseCase deleteTourImage;
  final SetPrimaryTourImageUseCase setPrimaryTourImage;

  AdminTourBloc({
    required this.getAdminTours,
    required this.createAdminTour,
    required this.deleteAdminTour,
    required this.uploadTourImage,
    required this.deleteTourImage,
    required this.setPrimaryTourImage,
  }) : super(AdminTourInitial()) {
    on<LoadAdminTours>(_onLoadTours);
    on<DeleteAdminTour>(_onDelete);
    on<CreateAdminTour>(_onCreate);
    on<UploadTourImage>(_onUploadTourImage);
    on<DeleteTourImage>(_onDeleteTourImage);
    on<SetPrimaryTourImage>(_onSetPrimaryTourImage);
  }

  Future<void> _onLoadTours(LoadAdminTours event, Emitter<AdminTourState> emit) async {
    emit(AdminTourLoading());
    try {
      final result = await getAdminTours(page: event.page);

      final dynamic rawContent = result['content'] ?? [];

      final List<AdminTourModel> tours = (rawContent as List)
          .map((e) => AdminTourModel.fromJson(e))
          .toList();

      emit(AdminTourLoaded(
        tours, // Lúc này tours đã đúng kiểu List<AdminTourModel>
        currentPage: result['number'] ?? 0,
        totalPages: result['totalPages'] ?? 1,
      ));
    } catch (e) {
      print("Lỗi LoadAdminTours: $e");
      emit(AdminTourError(e.toString()));
    }
  }

  Future<void> _onDelete(
      DeleteAdminTour event,
      Emitter<AdminTourState> emit,
      ) async {
    try {
      emit(AdminTourDeleteLoading());

      await deleteAdminTour(event.id);

      emit(AdminTourDeleteSuccess());

      add(const LoadAdminTours(page: 0));
    } catch (e) {
      emit(AdminTourDeleteError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateAdminTour event,
      Emitter<AdminTourState> emit,
      ) async {
    try {
      emit(AdminTourLoading());

      final tour = await createAdminTour(event.body);

      emit(AdminTourCreateSuccess(tour));

    } catch (e) {
      emit(AdminTourError(e.toString()));
    }
  }

  Future<void> _onUploadTourImage(
      UploadTourImage event,
      Emitter<AdminTourState> emit,
      ) async {
    try {
      emit(TourImageLoading());
      final image = await uploadTourImage(event.tourId, event.file);
      emit(UploadTourImageSuccess(image));
    } catch (e) {
      emit(TourImageError(e.toString()));
    }
  }

  Future<void> _onDeleteTourImage(
      DeleteTourImage event,
      Emitter<AdminTourState> emit,
      ) async {
    try {
      emit(TourImageLoading());
      await deleteTourImage(event.imageId);
      emit(TourImageActionSuccess());
    } catch (e) {
      emit(TourImageError(e.toString()));
    }
  }

  Future<void> _onSetPrimaryTourImage(
      SetPrimaryTourImage event,
      Emitter<AdminTourState> emit,
      ) async {
    try {
      emit(TourImageLoading());
      await setPrimaryTourImage(event.imageId);
      emit(TourImageActionSuccess());
    } catch (e) {
      emit(TourImageError(e.toString()));
    }
  }
}

