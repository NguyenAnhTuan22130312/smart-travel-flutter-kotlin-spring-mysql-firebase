import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/usecases/user/get_user_list.dart';
import 'package:smart_travel/domain/usecases/user/update_user_usecase.dart'
    as update_user_usecase;
import 'package:smart_travel/domain/usecases/user/lock_user_usecase.dart'
    as lock_user_usecase;
import 'package:smart_travel/domain/usecases/user/unlock_user_usecase.dart'
    as unlock_user_usecase;
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_event.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_state.dart';

class AdminUserBloc extends Bloc<AdminUserEvent, AdminUserState> {
  final GetUserList getUserList;
  final update_user_usecase.UpdateUser updateUser;
  final lock_user_usecase.LockUser lockUser;
  final unlock_user_usecase.UnlockUser unlockUser;

  // Store current parameters for pagination and sorting
  int _currentPage = 0;
  int _pageSize = 10;
  String? _searchKeyword;
  String _sortBy = 'createdAt';
  String _sortDirection = 'DESC';

  AdminUserBloc({
    required this.getUserList,
    required this.updateUser,
    required this.lockUser,
    required this.unlockUser,
  }) : super(AdminUserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<SearchUsers>(_onSearchUsers);
    on<ChangePage>(_onChangePage);
    on<ChangeSort>(_onChangeSort);
    on<UpdateUser>(_onUpdateUser);
    on<LockUser>(_onLockUser);
    on<UnlockUser>(_onUnlockUser);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<AdminUserState> emit,
  ) async {
    // If we already have data, show refreshing state instead of full loading
    if (state is AdminUserLoaded) {
      final currentState = state as AdminUserLoaded;
      emit(
        AdminUserLoaded(
          userResponse: currentState.userResponse,
          currentSearchKeyword: currentState.currentSearchKeyword,
          currentSortBy: currentState.currentSortBy,
          currentSortDirection: currentState.currentSortDirection,
          isRefreshing: true, // Show loading only in list area
        ),
      );
    } else {
      emit(AdminUserLoading()); // Initial load - full screen loading
    }

    // Update stored parameters
    _currentPage = event.page ?? _currentPage;
    _pageSize = event.size ?? _pageSize;
    _searchKeyword = event.searchKeyword;
    _sortBy = event.sortBy ?? _sortBy;
    _sortDirection = event.sortDirection ?? _sortDirection;

    final result = await getUserList(
      page: _currentPage,
      size: _pageSize,
      searchKeyword: _searchKeyword,
      sortBy: _sortBy,
      sortDirection: _sortDirection,
    );

    result.fold(
      (failure) => emit(AdminUserError(failure.message)),
      (userResponse) => emit(
        AdminUserLoaded(
          userResponse: userResponse,
          currentSearchKeyword: _searchKeyword,
          currentSortBy: _sortBy,
          currentSortDirection: _sortDirection,
          isRefreshing: false,
        ),
      ),
    );
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<AdminUserState> emit,
  ) async {
    _searchKeyword = event.keyword.isEmpty ? null : event.keyword;
    _currentPage = 0; // Reset to first page on search

    add(
      LoadUsers(
        page: _currentPage,
        size: _pageSize,
        searchKeyword: _searchKeyword,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      ),
    );
  }

  Future<void> _onChangePage(
    ChangePage event,
    Emitter<AdminUserState> emit,
  ) async {
    _currentPage = event.page;

    add(
      LoadUsers(
        page: _currentPage,
        size: _pageSize,
        searchKeyword: _searchKeyword,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      ),
    );
  }

  Future<void> _onChangeSort(
    ChangeSort event,
    Emitter<AdminUserState> emit,
  ) async {
    _sortBy = event.sortBy;
    _sortDirection = event.sortDirection;
    _currentPage = 0; // Reset to first page on sort change

    add(
      LoadUsers(
        page: _currentPage,
        size: _pageSize,
        searchKeyword: _searchKeyword,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      ),
    );
  }

  Future<void> _onUpdateUser(
    UpdateUser event,
    Emitter<AdminUserState> emit,
  ) async {
    emit(AdminUserUpdateLoading());

    final result = await updateUser(
      userId: event.userId,
      fullName: event.fullName,
      phone: event.phone,
      role: event.role,
    );

    result.fold((failure) => emit(AdminUserUpdateError(failure.message)), (_) {
      emit(const AdminUserUpdateSuccess('Cập nhật người dùng thành công'));
      // Reload the user list
      add(
        LoadUsers(
          page: _currentPage,
          size: _pageSize,
          searchKeyword: _searchKeyword,
          sortBy: _sortBy,
          sortDirection: _sortDirection,
        ),
      );
    });
  }

  Future<void> _onLockUser(LockUser event, Emitter<AdminUserState> emit) async {
    emit(AdminUserLockLoading());

    final result = await lockUser(event.userId);

    result.fold((failure) => emit(AdminUserLockError(failure.message)), (_) {
      emit(const AdminUserLockSuccess('Đã khóa tài khoản thành công'));
      // Reload the user list
      add(
        LoadUsers(
          page: _currentPage,
          size: _pageSize,
          searchKeyword: _searchKeyword,
          sortBy: _sortBy,
          sortDirection: _sortDirection,
        ),
      );
    });
  }

  Future<void> _onUnlockUser(
    UnlockUser event,
    Emitter<AdminUserState> emit,
  ) async {
    emit(AdminUserUnlockLoading());

    final result = await unlockUser(event.userId);

    result.fold((failure) => emit(AdminUserUnlockError(failure.message)), (_) {
      emit(const AdminUserUnlockSuccess('Đã mở khóa tài khoản thành công'));
      // Reload the user list
      add(
        LoadUsers(
          page: _currentPage,
          size: _pageSize,
          searchKeyword: _searchKeyword,
          sortBy: _sortBy,
          sortDirection: _sortDirection,
        ),
      );
    });
  }
}
