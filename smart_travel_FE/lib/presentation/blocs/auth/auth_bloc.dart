import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/usecases/auth/facebook_login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/forgot_password_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/google_login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/register_use_case.dart';
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
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final token = await authLocalDataSource.getToken();
    if (token != null && token.isNotEmpty) {
      final role = await authLocalDataSource.getRole();
      if (role == 'ADMIN') {
        emit(AdminAuthenticated(role!));
      } else {
        emit(UserAuthenticated(role!));
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event,
      Emitter<AuthState> emit,) async {
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

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (response) => emit(LoginSuccess(response)),
    );
  }

  Future<void> _onForgotPasswordSubmitted(ForgotPasswordSubmitted event,
      Emitter<AuthState> emit,) async {
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

    result.fold(
          (failure) {
        emit(AuthError(failure.message));
      },
          (auth) {
        emit(LoginSuccess(auth));
      },
    );
  }

  Future<void> _onFacebookLoginSubmitted(
      FacebookLoginSubmitted event,
      Emitter<AuthState> emit,) async {
    emit(AuthLoading());

    final result = await facebookLoginUseCase(NoParams());

    result.fold(
          (failure) {
        emit(AuthError(failure.message));
      },
          (auth) {
        emit(LoginSuccess(auth));
      },
    );
  }
}
