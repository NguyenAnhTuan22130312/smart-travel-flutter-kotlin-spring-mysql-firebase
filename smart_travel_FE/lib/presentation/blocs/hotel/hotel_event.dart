import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:smart_travel/data/models/hotel/hotel_create_request.dart';

abstract class HotelEvent extends Equatable {
  const HotelEvent();

  @override
  List<Object?> get props => [];
}

// Event gọi API lấy danh sách khách sạn
class LoadHotelsEvent extends HotelEvent {
  final int? destinationId;
  final String? keyword;
  final int? minStars;
  final int? maxStars;
  final double? minPrice;
  final double? maxPrice;
  final String? city;
  final int page;
  final int size;
  final String? sortBy;
  final String? sortDir;

  const LoadHotelsEvent({
    this.destinationId,
    this.keyword,
    this.minStars,
    this.maxStars,
    this.minPrice,
    this.maxPrice,
    this.city,
    this.page = 0,
    this.size = 10,
    this.sortBy = 'pricePerNight',
    this.sortDir = 'asc',
  });

  @override
  List<Object?> get props => [
    destinationId,
    keyword,
    minStars,
    maxStars,
    minPrice,
    maxPrice,
    city,
    page,
    size,
    sortBy,
    sortDir,
  ];
}

// --- Các Event cho CRUD ---

// 1. Tạo mới khách sạn
class CreateHotelEvent extends HotelEvent {
  final HotelCreateRequest request;

  const CreateHotelEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

// 2. Cập nhật khách sạn
class UpdateHotelEvent extends HotelEvent {
  final int hotelId;
  final HotelCreateRequest request;

  const UpdateHotelEvent({required this.hotelId, required this.request});

  @override
  List<Object?> get props => [hotelId, request];
}

// 3. Xóa khách sạn
class DeleteHotelEvent extends HotelEvent {
  final int hotelId;
  const DeleteHotelEvent({required this.hotelId});

  @override
  List<Object?> get props => [hotelId];
}

// 5. Event Upload
class UploadHotelImagesEvent extends HotelEvent {
  final int hotelId;
  final List<File> images;

  const UploadHotelImagesEvent({required this.hotelId, required this.images});

  @override
  List<Object?> get props => [hotelId, images];
}

// 6. Event Delete Image
class DeleteHotelImageEvent extends HotelEvent {
  final int hotelId; // Cần hotelId để reload lại detail sau khi xóa
  final int imageId;

  const DeleteHotelImageEvent({required this.hotelId, required this.imageId});

  @override
  List<Object?> get props => [hotelId, imageId];
}
