import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/destinations.dart';

abstract class DestinationState extends Equatable {
  const DestinationState();

  @override
  List<Object?> get props => [];
}
class FeaturedDestinationInitial extends DestinationState {}

// State khi đang load
class FeaturedDestinationLoading extends DestinationState {}


// State khi load thành công
class FeaturedDestinationLoaded extends DestinationState {
  final List<DestinationEntity> destinations;
  final bool isLimited;

  const FeaturedDestinationLoaded(this.destinations, {this.isLimited = false});

  @override
  List<Object?> get props => [destinations];
}
// State khi có lỗi
class FeaturedDestinationError extends DestinationState {
  final String message;

  const FeaturedDestinationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Filter Destinations States (by category)
//Khởi tạo
class FilterDestinationInitial extends DestinationState {}

//Load
class FilterDestinationLoading extends DestinationState {}

//Dữ liệu trả về thành công
class FilterDestinationLoaded extends DestinationState {
  final List<DestinationEntity> destinations;
  final bool isLimited;

  FilterDestinationLoaded(this.destinations, {this.isLimited = false}); // true = chỉ load 6, có thể hiện "Xem tất cả"

}
 //Lỗi
class FilterDestinationError extends DestinationState {
  final String message;
  FilterDestinationError(this.message);
}

//Load để lấy dữu liệu chi tiết địa điểm
class GetDetailDestinationLoading extends DestinationState{}
class GetDetailDestinationLoaded extends DestinationState{
  final DestinationEntity destinationEntity;
  GetDetailDestinationLoaded(this.destinationEntity);
}
class GetDetailDestinationError extends DestinationState{
  final String message;
  GetDetailDestinationError(this.message);
}








