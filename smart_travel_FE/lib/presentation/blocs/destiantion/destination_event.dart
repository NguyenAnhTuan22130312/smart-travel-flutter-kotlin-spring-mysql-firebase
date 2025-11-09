import 'package:equatable/equatable.dart';

abstract class DestinationEvent extends Equatable {

  @override
  List<Object?> get props => [];
}
// load danh sách điểm đến nổi bật
class LoadFeaturedDestinations extends DestinationEvent {
  final bool? loadAll;

  LoadFeaturedDestinations({this.loadAll = false});

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

//Xem chi tiết địa điểm
class GetDetailDestinationEvent extends DestinationEvent{
  final int id;
  GetDetailDestinationEvent(this.id);
}
