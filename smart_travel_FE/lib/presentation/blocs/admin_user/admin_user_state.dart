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
  final String? currentRoleFilter;
  final String? currentSortBy;
  final String? currentSortDirection;
  final bool isRefreshing; // For showing loading only in list area

  const AdminUserLoaded({
    required this.userResponse,
    this.currentSearchKeyword,
    this.currentRoleFilter,
    this.currentSortBy,
    this.currentSortDirection,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
    userResponse,
    currentSearchKeyword,
    currentRoleFilter,
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

// Update User States
class AdminUserUpdateLoading extends AdminUserState {}

class AdminUserUpdateSuccess extends AdminUserState {
  final String message;

  const AdminUserUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminUserUpdateError extends AdminUserState {
  final String message;

  const AdminUserUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

// Lock User States
class AdminUserLockLoading extends AdminUserState {}

class AdminUserLockSuccess extends AdminUserState {
  final String message;

  const AdminUserLockSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminUserLockError extends AdminUserState {
  final String message;

  const AdminUserLockError(this.message);

  @override
  List<Object?> get props => [message];
}

// Unlock User States
class AdminUserUnlockLoading extends AdminUserState {}

class AdminUserUnlockSuccess extends AdminUserState {
  final String message;

  const AdminUserUnlockSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminUserUnlockError extends AdminUserState {
  final String message;

  const AdminUserUnlockError(this.message);

  @override
  List<Object?> get props => [message];
}

// Create User States
class AdminUserCreateLoading extends AdminUserState {}

class AdminUserCreateSuccess extends AdminUserState {
  final String message;

  const AdminUserCreateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminUserCreateError extends AdminUserState {
  final String message;

  const AdminUserCreateError(this.message);

  @override
  List<Object?> get props => [message];
}
