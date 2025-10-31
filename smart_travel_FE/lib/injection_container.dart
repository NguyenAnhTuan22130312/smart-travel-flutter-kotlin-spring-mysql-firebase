import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:smart_travel/data/data_sources/local/auth_local_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/destination_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/province_data_source.dart';
import 'package:smart_travel/data/repositories/auth_repository_impl.dart';
import 'package:smart_travel/data/repositories/destination_repository_impl.dart';
import 'package:smart_travel/data/repositories/province_repository_impl.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';
import 'package:smart_travel/domain/repositories/province_repository.dart';
import 'package:smart_travel/domain/usecases/auth/facebook_login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/forgot_password_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/google_login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/register_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/filter_destinations_by_category_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_featured_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/province/get_all_province_use_case.dart';
import 'package:smart_travel/domain/usecases/province/province_detail_use_case.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/provicne_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/province_bloc.dart';

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
      googleLoginUseCase: sl(),
      facebookLoginUseCase: sl(),
    ),
  );

  //destination
  sl.registerFactory(
        () => DestinationBloc(
          destinationFeaturedUseCase : sl(),
          getAllDestinationUseCase: sl(),
          filterByCategoryUseCase: sl(),
    ),
  );

  //province
  sl.registerFactory(
        () => ProvinceBloc(
          getAllProvinceUseCase : sl(),
    ),
  );
  sl.registerFactory(
        () => ProvinceDetailBloc(
          provinceDetailUseCase : sl(),
    ),
  );

  // Use cases
  // auth
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(()=> GoogleLoginUseCase(sl()));
  sl.registerLazySingleton(()=> FacebookLoginUseCase(sl()));

  //  destination
  sl.registerLazySingleton(() => GetAllDestinationFeaturedUseCase(sl()));
  sl.registerLazySingleton(() => GetAllDestinationsUseCase(sl()));
  sl.registerLazySingleton(() => FilterDestinationsByCategoryUseCase(sl()));

  //  province
  sl.registerLazySingleton(() => GetAllProvinceUseCase(sl()));
  sl.registerLazySingleton(()=> ProvinceDetailUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      dataSource: sl(),
      networkInfo: sl(),
      localDataSource: sl(),
      firebaseAuth: sl(),
      googleSignIn: sl(),
      facebookAuth: sl(),
    ),
  );
  sl.registerLazySingleton<DestinationRepository>(
        () => DestinationRepositoryImpl(
      destinationDataSource: sl(),
      networkInfo: sl(),

    ),
  );
  sl.registerLazySingleton<ProvinceRepository>(
        () => ProvinceRepositoryImpl(
      provinceDataSource: sl(),
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
  sl.registerLazySingleton<ProvinceDataSource>(
        () => ProvinceDataSourceImpl(client: sl()),
  );


  //Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FacebookAuth>(() => FacebookAuth.instance);

  //External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => FlutterSecureStorage());
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

}