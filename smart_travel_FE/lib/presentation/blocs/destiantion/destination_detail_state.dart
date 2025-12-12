import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/destinations.dart';

class DestinationDetailState extends Equatable{

  const DestinationDetailState();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

//loading
class DestinationDetailLoading extends   DestinationDetailState{}

//loaded
class DestinationDetailLoaded  extends DestinationDetailState{
  final DestinationEntity response;

  const DestinationDetailLoaded(this.response);

  @override
  List<Object?> get props => [response];
}

//error
class DestinationDetailError extends DestinationDetailState{
  final String message;

  const DestinationDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

