import 'package:equatable/equatable.dart';

class DestinationDetailEvent extends Equatable{
  @override
  // TODO: implement props
  List<Object?> get props => [];

}
//Xem chi tiết địa điểm
class GetDetailDestinationEvent extends DestinationDetailEvent{
  final int id;
  GetDetailDestinationEvent(this.id);
}