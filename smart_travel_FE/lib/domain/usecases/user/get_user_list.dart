import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/data/models/admin/admin_user_response.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

class GetUserList {
  final UserRepository repository;

  GetUserList({required this.repository});

  Future<Either<Failure, AdminUserResponse>> call({
    int? page,
    int? size,
    String? searchKeyword,
    String? role,
    String? sortBy,
    String? sortDirection,
  }) async {
    return await repository.getUserList(
      page: page,
      size: size,
      searchKeyword: searchKeyword,
      role: role,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }
}
