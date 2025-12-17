import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/repositories/hotel_repository.dart';

class UploadHotelImagesUseCase extends UseCase<String, UploadHotelImagesParams> {
  final HotelRepository repository;

  UploadHotelImagesUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadHotelImagesParams params) async {
    return await repository.uploadHotelImages(params.hotelId, params.images);
  }
}

class UploadHotelImagesParams extends Equatable {
  final int hotelId;
  final List<File> images;

  const UploadHotelImagesParams({required this.hotelId, required this.images});

  @override
  List<Object?> get props => [hotelId, images];
}