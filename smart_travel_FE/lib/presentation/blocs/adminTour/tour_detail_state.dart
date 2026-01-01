import 'package:smart_travel/data/models/tour/admin_tour_model.dart';
import 'package:smart_travel/presentation/blocs/tour/tour_detail_state.dart';

abstract class AdminTourDetailState {}

class AdminTourDetailInitial extends AdminTourDetailState {}

class AdminTourDetailLoading extends AdminTourDetailState {}

class AdminTourDetailLoaded extends AdminTourDetailState {
  final AdminTourModel tour;
  AdminTourDetailLoaded(this.tour);
}

class AdminTourDetailError extends AdminTourDetailState {
  final String message;
  AdminTourDetailError(this.message);
}

class AdminTourUpdateLoading extends AdminTourDetailState {}
class AdminTourUpdateSuccess extends AdminTourDetailState {}

class AdminTourImageUpdating extends AdminTourDetailState {}

class AdminTourImageUpdated extends AdminTourDetailState {}
