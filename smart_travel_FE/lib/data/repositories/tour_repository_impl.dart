import 'package:smart_travel/data/models/tour/tour_detail_model.dart';
import 'package:smart_travel/domain/repositories/tour_repository.dart';
import 'package:smart_travel/domain/entities/tour_detail.dart';
import 'package:smart_travel/data/data_sources/remote/tour_remote_data_source.dart';
import 'package:smart_travel/core/error/exceptions.dart';

class TourRepositoryImpl implements TourRepository {
  final TourRemoteDataSource remote;

  TourRepositoryImpl(this.remote);

  @override
  Future<TourDetail> getTourDetail(int id) async {
    try {
      // Lấy chi tiết tour
      final detailModel = await remote.getTourDetail(id);
      if (detailModel == null) {
        throw ServerException("Không tìm thấy chi tiết tour với id = $id");
      }

      // Lấy danh sách ảnh tour
      final images = await remote.getTourImages(id);
      if (images == null) {
        throw ServerException("Không nhận được danh sách ảnh cho tour id = $id");
      }

      // Gộp vào model
      final updatedModel = TourDetailModel(
        id: detailModel.id,
        name: detailModel.name,
        description: detailModel.description,
        durationDays: detailModel.durationDays,
        durationNights: detailModel.durationNights,
        pricePerPerson: detailModel.pricePerPerson,
        averageRating: detailModel.averageRating,
        included: detailModel.included,
        excluded: detailModel.excluded,
        schedules: detailModel.schedules,
        images: images,
      );

      return updatedModel.toEntity();
    } catch (e) {
      // Bắt lỗi API hoặc decode
      throw ServerException("Lỗi khi tải chi tiết tour: ${e.toString()}");
    }
  }
}
