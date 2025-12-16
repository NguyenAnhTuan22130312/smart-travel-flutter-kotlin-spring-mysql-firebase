import 'package:equatable/equatable.dart';

abstract class AdminUserEvent extends Equatable {
  const AdminUserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends AdminUserEvent {
  final int? page;
  final int? size;
  final String? searchKeyword;
  final String? role;
  final String? sortBy;
  final String? sortDirection;

  const LoadUsers({
    this.page,
    this.size,
    this.searchKeyword,
    this.role,
    this.sortBy,
    this.sortDirection,
  });

  @override
  List<Object?> get props => [
    page,
    size,
    searchKeyword,
    role,
    sortBy,
    sortDirection,
  ];
}

class SearchUsers extends AdminUserEvent {
  final String keyword;

  const SearchUsers(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class ChangePage extends AdminUserEvent {
  final int page;

  const ChangePage(this.page);

  @override
  List<Object?> get props => [page];
}

class ChangeSort extends AdminUserEvent {
  final String sortBy;
  final String sortDirection;

  const ChangeSort({required this.sortBy, required this.sortDirection});

  @override
  List<Object?> get props => [sortBy, sortDirection];
}

class UpdateUser extends AdminUserEvent {
  final int userId;
  final String? fullName;
  final String? phone;
  final String? role;

  const UpdateUser({
    required this.userId,
    this.fullName,
    this.phone,
    this.role,
  });

  @override
  List<Object?> get props => [userId, fullName, phone, role];
}

class LockUser extends AdminUserEvent {
  final int userId;

  const LockUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UnlockUser extends AdminUserEvent {
  final int userId;

  const UnlockUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FilterRole extends AdminUserEvent {
  final String? role; // null = all, 'USER', 'ADMIN'

  const FilterRole(this.role);

  @override
  List<Object?> get props => [role];
}

class CreateUser extends AdminUserEvent {
  final String fullName;
  final String email;
  final String password;
  final String? phone;
  final String role;
  // Optional profile fields
  final String? gender;
  final String? dateOfBirth;
  final String? address;
  final String? city;
  final String? country;
  final String? bio;

  const CreateUser({
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
    this.role = 'USER',
    this.gender,
    this.dateOfBirth,
    this.address,
    this.city,
    this.country,
    this.bio,
  });

  @override
  List<Object?> get props => [
    fullName,
    email,
    password,
    phone,
    role,
    gender,
    dateOfBirth,
    address,
    city,
    country,
    bio,
  ];
}
