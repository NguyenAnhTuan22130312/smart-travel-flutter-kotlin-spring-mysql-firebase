import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/usecases/auth/forgot_password_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/register_use_case.dart';
import '../../../data/data_sources/local/auth_local_data_source.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUser;
  final LoginUseCase loginUseCase;
  final AuthLocalDataSource authLocalDataSource;
  final ForgotPasswordUseCase forgotPasswordUseCase;

  AuthBloc({
    required this.registerUser,
    required this.loginUseCase,
    required this.authLocalDataSource,
    required this.forgotPasswordUseCase,

  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);

  }


  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final token = await authLocalDataSource.getToken();

    if (token != null && token.isNotEmpty) {
      final role = await authLocalDataSource.getRole(); // lấy role từ storage
      emit(Authenticated(role ?? 'USER'));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await registerUser(event.request);

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (response) => emit(RegisterSuccess(response)),
    );
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await loginUseCase(event.requestModal);

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (response) => emit(LoginSuccess(response)),
    );
  }
  Future<void> _onForgotPasswordSubmitted(
      ForgotPasswordSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await forgotPasswordUseCase(event.email);

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (response) => emit(ForgotPasswordSuccess(response)),
    );
  }
}