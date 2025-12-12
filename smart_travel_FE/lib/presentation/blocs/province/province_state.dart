import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/province.dart';

class ProvinceState extends Equatable{
  const ProvinceState();
  @override
  // TODO: implement props
  @override
  List<Object?> get props => [];
}

///STATE DANH SÁCH TỈNH THÀNH
//State khi loading
class ProvinceLoading extends ProvinceState{
}

//Danh sách tỉnh thành phổ biến
class ProvincePopularLoading extends ProvinceState{
}
class ProvincePopularLoaded extends ProvinceState{
  final List<ProvinceEntity> province;
  const ProvincePopularLoaded(this.province);
  @override
  List<Object?> get props => [province];
}
class ProvincePopularError extends ProvinceState{
  final String message;
  const ProvincePopularError(this.message);
  @override
  List<Object?> get props => [message];
}


//State khi loading danh sách tỉnh thành, thành công
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

///STATE THÊM TỈNH THÀNH
// State khi đang thực hiện thêm mới (để hiện loading spinner trên nút bấm)
class ProvinceAdding extends ProvinceState {}
// State khi thêm thành công
class ProvinceAddSuccess extends ProvinceState {}
// state khi thêm tỉnh thành lỗi
class AddProvinceError extends ProvinceState{
  final String message;
  const AddProvinceError(this.message);
  @override
  List<Object?> get props => [message];
}

///STATE Cập nhật tỉnh thành
// State khi đang thực hiện thêm mới (để hiện loading spinner trên nút bấm)
class ProvinceUpdateLoading  extends ProvinceState {}
// State khi thêm thành công
class ProvinceUpdateSuccess extends ProvinceState {}
// state khi thêm tỉnh thành lỗi
class ProvinceUpdateError extends ProvinceState{
  final String message;
  const ProvinceUpdateError(this.message);
  @override
  List<Object?> get props => [message];
}


///STATE XÓA TỈNH THÀNH
class ProvinceDeleteLoading extends ProvinceState {}
// State khi xóa thành công/thất bại
class ProvinceDeleteSuccess extends ProvinceState {}
// State khi xóa thành công/thất bại
class ProvinceDeleteError extends ProvinceState {
  final String message;
  const ProvinceDeleteError(this.message);
  @override
  List<Object?> get props => [message];
}

