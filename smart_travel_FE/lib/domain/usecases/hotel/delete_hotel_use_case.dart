import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/repositories/hotel_repository.dart';

class DeleteHotelUseCase extends UseCase<String, int> {
  final HotelRepository repository;

  DeleteHotelUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(int id) async {
    return await repository.deleteHotel(id);
  }
}