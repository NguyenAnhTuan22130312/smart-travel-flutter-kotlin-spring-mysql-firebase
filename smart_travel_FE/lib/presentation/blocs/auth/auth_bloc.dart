import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/usecases/auth/facebook_login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/forgot_password_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/google_login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/register_use_case.dart';
// Import AuthEntity để biết kiểu dữ liệu
import 'package:smart_travel/domain/entities/auth.dart';
import '../../../core/usecases/usecase.dart';
import '../../../data/data_sources/local/auth_local_data_source.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUser;
  final LoginUseCase loginUseCase;
  final AuthLocalDataSource authLocalDataSource;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final GoogleLoginUseCase googleLoginUseCase;
  final FacebookLoginUseCase facebookLoginUseCase;

  AuthBloc( {
    required this.registerUser,
    required this.loginUseCase,
    required this.authLocalDataSource,
    required this.forgotPasswordUseCase,
    required this.googleLoginUseCase,
    required this.facebookLoginUseCase,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<GoogleLoginSubmitted>(_onGoogleLoginSubmitted);
    on<FacebookLoginSubmitted>(_onFacebookLoginSubmitted);
    // Lưu ý: Code cũ của bạn không có Logout, nếu cần bạn phải thêm
    // on<LogoutSubmitted>(_onLogoutSubmitted);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // (Giữ nguyên code cũ, đã đúng)
    emit(AuthLoading());
    final token = await authLocalDataSource.getToken();

    if (token != null && token.isNotEmpty) {
      final role = await authLocalDataSource.getRole(); // lấy role từ storage
      emit(Authenticated(role ?? 'USER'));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event,
      Emitter<AuthState> emit,) async {
    // (Giữ nguyên code cũ, đã đúng)
    emit(AuthLoading());
    final result = await registerUser(event.params);
    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (response) => emit(RegisterSuccess(response)),
    );
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event,
      Emitter<AuthState> emit,) async {
    emit(AuthLoading());
    final result = await loginUseCase(event.params);

    // --- SỬA LỖI TỔNG HỢP (SỬA CẢ 3 VẤN ĐỀ) ---
    await result.fold(
          (failure) async {
        // Thêm async/await để sửa lỗi emit
        emit(AuthError(failure.message));
      },
          (authResponse) async {
        // 1. SỬA LỖI TOKEN: Lưu token trước
        final token = authResponse.token;
        if (token == null || token.isEmpty) {
          emit(AuthError("Đăng nhập thất bại: Không nhận được token."));
          return;
        }
        final userRole = authResponse.role ?? 'USER';
        await authLocalDataSource.saveToken(token);
        await authLocalDataSource.saveRefreshToken(authResponse.refreshToken ?? '');
        await authLocalDataSource.saveRole(userRole);
        await authLocalDataSource.saveFullName(authResponse.fullName ?? '');

        // 2. GIỮ LOGIC CŨ: Vẫn emit LoginSuccess để UI của bạn bắt được
        emit(LoginSuccess(authResponse));
      },
    );
  }

  Future<void> _onForgotPasswordSubmitted(ForgotPasswordSubmitted event,
      Emitter<AuthState> emit,) async {
    // (Giữ nguyên code cũ, đã đúng)
    emit(AuthLoading());
    final result = await forgotPasswordUseCase(event.email);
    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (response) => emit(ForgotPasswordSuccess(response)),
    );
  }

  // Google Login Handler
  Future<void> _onGoogleLoginSubmitted(GoogleLoginSubmitted event,
      Emitter<AuthState> emit,) async {
    emit(AuthLoading());
    final result = await googleLoginUseCase(NoParams());

    // --- SỬA LỖI TỔNG HỢP (SỬA CẢ 3 VẤN ĐỀ) ---
    await result.fold(
          (failure) async {
        emit(AuthError(failure.message));
      },
          (authResponse) async {
        // 1. SỬA LỖI TOKEN: Lưu token trước
        final token = authResponse.token;
        if (token == null || token.isEmpty) {
          emit(AuthError("Đăng nhập thất bại: Không nhận được token."));
          return;
        }
        final userRole = authResponse.role ?? 'USER';
        await authLocalDataSource.saveToken(token);
        await authLocalDataSource.saveRefreshToken(authResponse.refreshToken ?? '');
        await authLocalDataSource.saveRole(userRole);
        await authLocalDataSource.saveFullName(authResponse.fullName ?? '');

        // 2. GIỮ LOGIC CŨ: Vẫn emit LoginSuccess để UI của bạn bắt được
        emit(LoginSuccess(authResponse));
      },
    );
  }

  Future<void> _onFacebookLoginSubmitted(
      FacebookLoginSubmitted event,
      Emitter<AuthState> emit,) async {
    emit(AuthLoading());
    final result = await facebookLoginUseCase(NoParams());

    // --- SỬA LỖI TỔNG HỢP (SỬA CẢ 3 VẤN ĐỀ) ---
    await result.fold(
          (failure) async {
        emit(AuthError(failure.message));
      },
          (authResponse) async {
        // 1. SỬA LỖI TOKEN: Lưu token trước
        final token = authResponse.token;
        if (token == null || token.isEmpty) {
          emit(AuthError("Đăng nhập thất bại: Không nhận được token."));
          return;
        }
        final userRole = authResponse.role ?? 'USER';
        await authLocalDataSource.saveToken(token);
        await authLocalDataSource.saveRefreshToken(authResponse.refreshToken ?? '');
        await authLocalDataSource.saveRole(userRole);
        await authLocalDataSource.saveFullName(authResponse.fullName ?? '');

        // 2. GIỮ LOGIC CŨ: Vẫn emit LoginSuccess để UI của bạn bắt được
        emit(LoginSuccess(authResponse));
      },
    );
  }
}

