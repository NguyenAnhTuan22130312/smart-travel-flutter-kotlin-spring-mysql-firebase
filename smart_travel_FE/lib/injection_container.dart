import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:smart_travel/data/data_sources/local/auth_local_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/destination_data_source.dart';
import 'package:smart_travel/data/repositories/auth_repository_impl.dart';
import 'package:smart_travel/data/repositories/destination_repository_impl.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';
import 'package:smart_travel/domain/usecases/auth/forgot_password_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/register_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_featured_use_case.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';

import 'core/network/network_info.dart';
import 'data/data_sources/remote/auth_remote_datasource.dart';
final sl = GetIt.instance;

Future<void> init() async {
  // Features - Authentication
  // Bloc
  sl.registerFactory(
        () => AuthBloc(
      registerUser: sl(),
      loginUseCase: sl(),
      authLocalDataSource: sl(),
      forgotPasswordUseCase: sl(),
    ),
  );
  sl.registerFactory(
        () => DestinationBloc(
          destinationFeaturedUseCase : sl(),
    ),
  );

  // Use cases
  // auth
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  //  destination
  sl.registerLazySingleton(() => GetAllDestinationFeaturedUseCase(sl()));


  // Repository
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      dataSource: sl(),
      networkInfo: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<DestinationRepository>(
        () => DestinationRepositoryImpl(
      destinationDataSource: sl(),
      networkInfo: sl(),

    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthDataSource>(
        () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(storage: sl()),
  );
  sl.registerLazySingleton<DestinationDataSource>(
        () => DestinationDataSourceImpl(client: sl()),
  );


  //Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => FlutterSecureStorage());

}