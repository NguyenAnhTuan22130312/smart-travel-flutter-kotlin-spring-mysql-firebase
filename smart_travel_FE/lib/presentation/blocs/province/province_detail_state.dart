import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/province.dart';

class ProvinceDetailState extends Equatable{

  const ProvinceDetailState();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

//loading
class ProvinceDetailLoading extends   ProvinceDetailState{}

//loaded
class ProvinceDetailLoaded  extends ProvinceDetailState{
  final ProvinceEntity response;

  const ProvinceDetailLoaded(this.response);

  @override
  List<Object?> get props => [response];
}

//error
class ProvinceDetailError extends ProvinceDetailState{
  final String message;

  const ProvinceDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

