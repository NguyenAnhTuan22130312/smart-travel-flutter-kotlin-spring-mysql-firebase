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

class FilterDestinationsByCategory extends DestinationEvent {
  final String category;
  FilterDestinationsByCategory(this.category);
}
class LoadAllDestinations extends DestinationEvent {
  final bool? loadAll;

  LoadAllDestinations({this.loadAll = false});
}

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

class SearchDestinationEvent extends DestinationEvent{
  final String query;

  SearchDestinationEvent(this.query);

}
