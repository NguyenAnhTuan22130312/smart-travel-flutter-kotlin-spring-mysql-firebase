import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/province.dart';

class ProvinceState extends Equatable{
  const ProvinceState();
  @override
  // TODO: implement props
  @override
  List<Object?> get props => [];
}

//State khi loading
class ProvinceLoading extends ProvinceState{
}


//State khi loading thành công
class ProvincePopularLoaded extends ProvinceState{
  final List<ProvinceEntity> province;

  const ProvincePopularLoaded(this.province);

  @override
  List<Object?> get props => [province];

}
//State khi loading thành công
class ProvinceLoaded extends ProvinceState{
  final List<ProvinceEntity> province;

  const ProvinceLoaded(this.province);

  @override
  List<Object?> get props => [province];
}

// State khi có lỗi
class ProvinceError extends ProvinceState{
  final String message;

  const ProvinceError(this.message);
  @override
  List<Object?> get props => [message];
}

// state khi thêm tỉnh thành lỗi
class AddProvinceError extends ProvinceState{
  final String message;

  const AddProvinceError(this.message);
  @override
  List<Object?> get props => [message];
}
