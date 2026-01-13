import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/usecases/hotel/create_hotel_use_case.dart';
import 'package:smart_travel/domain/usecases/hotel/delete_hotel_use_case.dart';
import 'package:smart_travel/domain/usecases/hotel/get_hotels_use_case.dart';
import 'package:smart_travel/domain/usecases/hotel/update_hotel_use_case.dart';
import 'package:smart_travel/domain/usecases/hotel/upload_hotel_images_use_case.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_event.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_state.dart';

class HotelBloc extends Bloc<HotelEvent, HotelState> {
  final GetHotelsUseCase getHotelsUseCase;
  final CreateHotelUseCase createHotelUseCase;
  final UpdateHotelUseCase updateHotelUseCase;
  final DeleteHotelUseCase deleteHotelUseCase;
  final UploadHotelImagesUseCase uploadHotelImagesUseCase;

  // 1. BIẾN LƯU TRỮ TRẠNG THÁI LOAD CUỐI CÙNG (Để reload đúng trang/filter)
  LoadHotelsEvent _lastLoadEvent = const LoadHotelsEvent();

  HotelBloc({
    required this.getHotelsUseCase,
    required this.createHotelUseCase,
    required this.updateHotelUseCase,
    required this.deleteHotelUseCase,
    required this.uploadHotelImagesUseCase,
  }) : super(HotelInitial()) {
    on<LoadHotelsEvent>(_onLoadHotelsEvent);
    on<CreateHotelEvent>(_onCreateHotelEvent);
    on<UpdateHotelEvent>(_onUpdateHotelEvent);
    on<DeleteHotelEvent>(_onDeleteHotelEvent);
    on<UploadHotelImagesEvent>(_onUploadImages);
  }

  Future<void> _onLoadHotelsEvent(
    LoadHotelsEvent event,
    Emitter<HotelState> emit,
  ) async {
    // 2. LƯU LẠI EVENT MỚI NHẤT
    _lastLoadEvent = event;
    emit(HotelLoading());

    emit(HotelLoading());
    final result = await getHotelsUseCase(
      GetHotelsParams(
        destinationId: event.destinationId,
        keyword: event.keyword,
        minStars: event.minStars,
        maxStars: event.maxStars,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        city: event.city,
        page: event.page,
        size: event.size,
        sortBy: event.sortBy,
        sortDir: event.sortDir,
      ),
    );

    result.fold((failure) => emit(HotelError(failure.message)), (pageData) {
      emit(
        HotelLoaded(
          hotels: pageData.content,
          currentPage: pageData.pageNumber,
          totalPages: pageData.totalPages,
        ),
      );
    });
  }

// --- 1. TẠO MỚI ---
  Future<void> _onCreateHotelEvent(
      CreateHotelEvent event,
      Emitter<HotelState> emit,
      ) async {
    emit(HotelLoading());

    final result = await createHotelUseCase(event.request);

    await result.fold(
          (failure) async => emit(HotelError(failure.message)),
          (hotelCreated) async {
        // 1. Nếu có ảnh, phải ĐỢI upload xong hoàn toàn
        if (event.imageFile != null) {
          developer.log(">>> Đang upload ảnh bìa cho Hotel mới ID: ${hotelCreated.id}");

          await uploadHotelImagesUseCase(
            UploadHotelImagesParams(
              hotelId: hotelCreated.id,
              images: [event.imageFile!],
            ),
          );
          await Future.delayed(const Duration(milliseconds: 500));
        }

        // 2. CHỈ KHI XONG TẤT CẢ MỚI BÁO THÀNH CÔNG
        emit(HotelOperationSuccess("Tạo khách sạn và tải ảnh thành công!"));
        final checkPageResult = await getHotelsUseCase(
          GetHotelsParams(
            keyword: _lastLoadEvent.keyword,
            destinationId: _lastLoadEvent.destinationId,
            city: _lastLoadEvent.city,
            minPrice: _lastLoadEvent.minPrice,
            maxPrice: _lastLoadEvent.maxPrice,
            minStars: _lastLoadEvent.minStars,
            maxStars: _lastLoadEvent.maxStars,
            page: 0,
            size: _lastLoadEvent.size,
          ),
        );
        int targetPage = 0;

        checkPageResult.fold(
                (l) => targetPage = 0, // Nếu lỗi thì về trang 0
                (pageData) {
              // Trang cuối cùng = Tổng số trang - 1
              targetPage = pageData.totalPages > 0 ? pageData.totalPages - 1 : 0;
            }
        );

        // 3. Reload data (Có thể để delay ngắn trước khi add event load)
        add(LoadHotelsEvent(
            keyword: _lastLoadEvent.keyword,
            destinationId: _lastLoadEvent.destinationId,
            city: _lastLoadEvent.city,
            minPrice: _lastLoadEvent.minPrice,
            maxPrice: _lastLoadEvent.maxPrice,
            minStars: _lastLoadEvent.minStars,
            maxStars: _lastLoadEvent.maxStars,
            page: targetPage,
            sortBy: 'id',
            sortDir: 'asc'
        ));
      },
    );
  }

  // --- 2. CẬP NHẬT ---
  Future<void> _onUpdateHotelEvent(
    UpdateHotelEvent event,
    Emitter<HotelState> emit,
  ) async {
    final result = await updateHotelUseCase(
      UpdateHotelParams(id: event.hotelId, request: event.request),
    );

    await result.fold((failure) async => emit(HotelError(failure.message)), (
      success,
    ) async {
      emit(HotelOperationSuccess("Cập nhật khách sạn thành công"));
      await Future.delayed(const Duration(milliseconds: 500));
      add(_lastLoadEvent);
    });
  }

  // --- 3. XÓA ---
  Future<void> _onDeleteHotelEvent(DeleteHotelEvent event, Emitter<HotelState> emit) async {
    emit(DeleteHotelLoading());

    final result = await deleteHotelUseCase(event.hotelId);

    await result.fold(
          (failure) async => emit(DeleteHotelError(failure.message)),
          (success) async {
        emit(HotelOperationSuccess("Xóa khách sạn thành công"));
        await Future.delayed(const Duration(milliseconds: 500));
        add(_lastLoadEvent);
      },
    );
  }

  // --- 4. UPLOAD ẢNH ---
  Future<void> _onUploadImages(
    UploadHotelImagesEvent event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());
    final result = await uploadHotelImagesUseCase(
      UploadHotelImagesParams(hotelId: event.hotelId, images: event.images),
    );

    await result.fold((failure) async => emit(HotelError(failure.message)), (
      success,
    ) async {
      emit(HotelOperationSuccess("Upload ảnh thành công"));
      emit(HotelLoading());
      add(_lastLoadEvent);
    });
  }
}
