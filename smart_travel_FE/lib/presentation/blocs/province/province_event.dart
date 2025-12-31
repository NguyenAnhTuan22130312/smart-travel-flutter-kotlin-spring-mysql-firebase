import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/province.dart';
import 'package:smart_travel/domain/params/province_add_params.dart';
import 'package:smart_travel/domain/params/province_update_params.dart';

class ProvinceEvent extends Equatable{
  @override
  // TODO: implement props
  List<Object?> get props => [];

}
//Load danh sách tỉnh thành phổ biến
class LoadProvinceIsPopular extends ProvinceEvent{
}

class LoadProvince extends ProvinceEvent{
  final bool? loadAll;
  LoadProvince({this.loadAll = false});

}

class AddProvince extends ProvinceEvent {
  final ProvinceAddParams params;
  AddProvince(this.params);
  @override
  List<Object?> get props => [params];
}

class DeleteProvince extends ProvinceEvent {
  final int provinceId;
  DeleteProvince(this.provinceId);
  @override
  List<Object?> get props => [provinceId];
}

class UpdateProvince extends ProvinceEvent {
  final ProvinceUpdateParams params;
  UpdateProvince(this.params);
  @override
  List<Object?> get props => [params];
}