import 'package:smart_travel/presentation/blocs/tour/tour_detail_event.dart';

abstract class AdminTourDetailEvent {}

class LoadAdminTourDetail extends AdminTourDetailEvent {
  final int id;
  LoadAdminTourDetail(this.id);
}
class UpdateAdminTourDetail extends AdminTourDetailEvent {
  final int id;
  final Map<String, dynamic> body;

  UpdateAdminTourDetail(this.id, this.body);
}
class SetPrimaryAdminTourImage extends AdminTourDetailEvent {
  final int imageId;
  final int tourId;

  SetPrimaryAdminTourImage({
    required this.imageId,
    required this.tourId,
  });
}
class DeleteAdminTourImage extends AdminTourDetailEvent {
  final int tourId;
  final int imageId;

  DeleteAdminTourImage({required this.tourId, required this.imageId});
}
