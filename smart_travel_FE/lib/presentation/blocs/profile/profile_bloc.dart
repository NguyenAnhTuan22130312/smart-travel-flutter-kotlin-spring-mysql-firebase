import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/usecases/user/get_profile_usecase.dart';
import 'package:smart_travel/domain/usecases/user/update_profile_usecase.dart';
import 'package:smart_travel/domain/usecases/user/change_password_usecase.dart';
import 'package:smart_travel/domain/usecases/user/get_settings_usecase.dart';
import 'package:smart_travel/domain/usecases/user/update_settings_usecase.dart';
import 'package:smart_travel/domain/usecases/user/get_level_usecase.dart';
import 'package:smart_travel/domain/usecases/user/delete_account_usecase.dart';
import 'package:smart_travel/domain/usecases/user/logout_usecase.dart';
import 'package:smart_travel/domain/entities/user.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final GetSettingsUseCase getSettingsUseCase;
  final UpdateSettingsUseCase updateSettingsUseCase;
  final GetLevelUseCase getLevelUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final LogoutUseCase logoutUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
    required this.getSettingsUseCase,
    required this.updateSettingsUseCase,
    required this.getLevelUseCase,
    required this.deleteAccountUseCase,
    required this.logoutUseCase,
  }) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<ChangePassword>(_onChangePassword);
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
    on<LoadLevel>(_onLoadLevel);
    on<DeleteAccount>(_onDeleteAccount);
    on<Logout>(_onLogout);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getProfileUseCase();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await updateProfileUseCase(
      fullName: event.fullName,
      phone: event.phone,
      avatarUrl: event.avatarUrl,
      bio: event.bio,
      gender: event.gender,
      dateOfBirth: event.dateOfBirth,
      address: event.address,
      city: event.city,
      country: event.country,
    );

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileUpdateSuccess(user, 'Cập nhật profile thành công')),
    );
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await changePasswordUseCase(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      confirmNewPassword: event.confirmNewPassword,
    );

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const PasswordChangeSuccess('Đổi mật khẩu thành công')),
    );
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getSettingsUseCase();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await updateSettingsUseCase(
      languageSettings: event.languageSettings,
      darkModeEnabled: event.darkModeEnabled,
      notificationSettings: event.notificationSettings,
    );

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (settings) =>
          emit(SettingsUpdateSuccess(settings, 'Cập nhật cài đặt thành công')),
    );
  }

  Future<void> _onLoadLevel(LoadLevel event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    final result = await getLevelUseCase();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (level) => emit(LevelLoaded(level)),
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await deleteAccountUseCase();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) =>
          emit(const AccountDeletedSuccess('Tài khoản đã được xóa thành công')),
    );
  }

  Future<void> _onLogout(Logout event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    final result = await logoutUseCase();

    result.fold((failure) => emit(ProfileError(failure.message)), (_) {
      // Emit logout success with default settings to reset UI theme
      const defaultSettings = UserSettings(
        darkModeEnabled: false,
        languageSettings: null,
        notificationSettings: null,
      );
      emit(LogoutSuccess(defaultSettings: defaultSettings));
    });
  }
}
