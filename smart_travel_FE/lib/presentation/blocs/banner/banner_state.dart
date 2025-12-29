import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/banner.dart';

abstract class BannerState extends Equatable {
  const BannerState();
  @override
  List<Object?> get props => [];
}

/// Trạng thái khởi tạo
class BannerInitial extends BannerState {}

// --- STATES CHO VIỆC LOAD DANH SÁCH ---

/// Đang tải danh sách banner
class BannerDataLoading extends BannerState {}

/// Đã tải danh sách thành công
class BannerData extends BannerState {
  final List<BannerEntity> banners;

  const BannerData(this.banners);

  @override
  List<Object?> get props => [banners];
}

/// Lỗi khi lấy danh sách
class BannerDataError extends BannerState {
  final String message;

  const BannerDataError(this.message);

  @override
  List<Object?> get props => [message];
}


class BannerActionLoading extends BannerState {}

class BannerActionSuccess extends BannerState {
  final String message;
  final BannerEntity? banner;

  const BannerActionSuccess({required this.message, this.banner});

  @override
  List<Object?> get props => [message, banner];
}

class BannerActionError extends BannerState {
  final String message;

  const BannerActionError(this.message);

  @override
  List<Object?> get props => [message];
}