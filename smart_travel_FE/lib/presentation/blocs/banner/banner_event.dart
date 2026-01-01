import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/params/banner_create_params.dart';
import 'package:smart_travel/domain/params/banner_update_params.dart';

abstract class BannerEvent extends Equatable {
  const BannerEvent();
  @override
  List<Object?> get props => [];
}
class LoadAllBanner extends BannerEvent{
}
/// Event thêm mới banner
class CreateBannerEvent extends BannerEvent {
  final BannerCreateParams params;

  const CreateBannerEvent(this.params);

  @override
  List<Object?> get props => [params];
}

/// Event cập nhật banner
class UpdateBannerEvent extends BannerEvent {
  final BannerUpdateParams params;

  const UpdateBannerEvent(this.params);

  @override
  List<Object?> get props => [params];
}

/// Event xóa banner
class DeleteBannerEvent extends BannerEvent {
  final int id;

  const DeleteBannerEvent(this.id);

  @override
  List<Object?> get props => [id];
}