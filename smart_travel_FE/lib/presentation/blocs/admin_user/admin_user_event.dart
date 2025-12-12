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
  final String? sortBy;
  final String? sortDirection;

  const LoadUsers({
    this.page,
    this.size,
    this.searchKeyword,
    this.sortBy,
    this.sortDirection,
  });

  @override
  List<Object?> get props => [page, size, searchKeyword, sortBy, sortDirection];
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
