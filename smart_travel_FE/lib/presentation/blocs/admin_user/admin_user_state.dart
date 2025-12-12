import 'package:equatable/equatable.dart';
import 'package:smart_travel/data/models/admin/admin_user_response.dart';

abstract class AdminUserState extends Equatable {
  const AdminUserState();

  @override
  List<Object?> get props => [];
}

class AdminUserInitial extends AdminUserState {}

class AdminUserLoading extends AdminUserState {}

class AdminUserLoaded extends AdminUserState {
  final AdminUserResponse userResponse;
  final String? currentSearchKeyword;
  final String? currentSortBy;
  final String? currentSortDirection;
  final bool isRefreshing; // For showing loading only in list area

  const AdminUserLoaded({
    required this.userResponse,
    this.currentSearchKeyword,
    this.currentSortBy,
    this.currentSortDirection,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
    userResponse,
    currentSearchKeyword,
    currentSortBy,
    currentSortDirection,
    isRefreshing,
  ];
}

class AdminUserError extends AdminUserState {
  final String message;

  const AdminUserError(this.message);

  @override
  List<Object?> get props => [message];
}
