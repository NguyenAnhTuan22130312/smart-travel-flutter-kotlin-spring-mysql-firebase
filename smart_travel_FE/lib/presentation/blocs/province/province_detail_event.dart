import 'package:equatable/equatable.dart';

class ProvinceDetailEvent extends Equatable{
  @override
  // TODO: implement props
  List<Object?> get props => [];

}
class LoadProvinceDetail extends ProvinceDetailEvent{
  final int provinceId;

  LoadProvinceDetail({required this.provinceId});

}