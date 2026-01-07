import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/params/destination_add_params.dart';
import 'package:smart_travel/domain/params/destination_update_params.dart';
import 'package:smart_travel/domain/params/get_weather_params.dart';

abstract class DestinationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

//Lọc địa điểm theo danh mục
class FilterDestinationsByCategory extends DestinationEvent {
  final String category;
  FilterDestinationsByCategory(this.category);
}

// Lấy danh sách địa điểm
class LoadAllDestinations extends DestinationEvent {
  final bool? loadAll;

  LoadAllDestinations({this.loadAll = false});
}

//lọc địa điểm theo giá trị
class FilterDestinationsEvent extends DestinationEvent {
  final String? sortBy;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;

  FilterDestinationsEvent({
    this.sortBy,
    this.minPrice,
    this.maxPrice,
    this.minRating,
  });

}

//Tìm kiếm địa điểm
class SearchDestinationEvent extends DestinationEvent{
  final String query;

  SearchDestinationEvent(this.query);

}


//thêm địa điểm
class AddDestinationEvent extends DestinationEvent{
  final DestinationAddParams destinationAddParams;
  AddDestinationEvent(this.destinationAddParams);
}
//Cập nhật địa điểm
class UpdateDestinationEvent extends DestinationEvent{
  final DestinationUpdateParams destinationUpdateParams;
  UpdateDestinationEvent(this.destinationUpdateParams);
}
//Xóa địa điểm
class DeleteDestinationEvent extends DestinationEvent{
  final int destinationId;
  DeleteDestinationEvent(this.destinationId);
}

class CompleteVoiceEvent extends DestinationEvent {
  final int destinationId;
  CompleteVoiceEvent(this.destinationId);
  @override
  List<Object?> get props => [destinationId];
}