import 'package:smart_travel/domain/entities/hotel.dart';

class HotelsPage {
  final List<Hotel> content;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalElements;
  final bool last;

  HotelsPage({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalElements,
    required this.last,
  });
}
