import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:smart_travel/core/services/image_upload_service.dart';
import 'package:smart_travel/data/data_sources/local/auth_local_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/destination_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/hotel_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/province_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/user_remote_datasource.dart';
import 'package:smart_travel/data/repositories/auth_repository_impl.dart';
import 'package:smart_travel/data/repositories/destination_repository_impl.dart';
import 'package:smart_travel/data/repositories/hotel_repository_impl.dart';
import 'package:smart_travel/data/repositories/province_repository_impl.dart';
import 'package:smart_travel/data/repositories/user_repository_impl.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';
import 'package:smart_travel/domain/repositories/hotel_repository.dart';
import 'package:smart_travel/domain/repositories/province_repository.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';
import 'package:smart_travel/domain/usecases/auth/facebook_login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/forgot_password_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/google_login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/register_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/filter_destinations_by_category_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_featured_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_detail_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/hotel/get_hotels_use_case.dart';
import 'package:smart_travel/domain/usecases/hotel/hotel_detail_use_case.dart';
import 'package:smart_travel/domain/usecases/province/add_province_use_case.dart';
import 'package:smart_travel/domain/usecases/province/delete_province_use_case.dart';
import 'package:smart_travel/domain/usecases/province/get_all_province_use_case.dart';
import 'package:smart_travel/domain/usecases/province/province_detail_use_case.dart';
import 'package:smart_travel/domain/usecases/province/update_province_use_case.dart';
import 'package:smart_travel/domain/usecases/user/get_profile_usecase.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_bloc.dart';
import 'package:smart_travel/presentation/blocs/chat/chat_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotail_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/provicne_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/province_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/data/repositories/payment_repository_impl.dart';
import 'package:smart_travel/domain/repositories/payment_repository.dart';
import 'package:smart_travel/domain/usecases/payment/confirm_cash_usecase.dart';
import 'package:smart_travel/domain/usecases/payment/process_payment_usecase.dart';
import 'package:smart_travel/presentation/blocs/payment/payment_bloc.dart';
import 'package:smart_travel/presentation/blocs/booking/booking_bloc.dart';
import 'core/network/network_info.dart';
import 'data/data_sources/remote/auth_remote_datasource.dart';
import 'package:smart_travel/data/data_sources/remote/booking_data_source.dart';
import 'package:smart_travel/data/repositories/booking_repository_impl.dart';
import 'package:smart_travel/domain/repositories/booking_repository.dart';
import 'package:smart_travel/domain/usecases/booking/create_booking_usecase.dart';
import 'package:smart_travel/data/data_sources/remote/tour_remote_data_source.dart';
import 'package:smart_travel/data/repositories/tour_repository_impl.dart';
import 'package:smart_travel/domain/repositories/tour_repository.dart';
import 'package:smart_travel/presentation/blocs/tour/tour_bloc.dart';
import 'package:smart_travel/domain/usecases/tour/get_tour_detail_usecase.dart';

import 'data/repositories/chat_repository_impl.dart';

final sl = GetIt.instance;

//PHẦN ĐẦU - External & Core
Future<void> init() async {
  //External dependencies
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => FlutterSecureStorage());
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  sl.registerLazySingleton(() => Dio());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Core services
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FacebookAuth>(() => FacebookAuth.instance);

  //PHẦN QUAN TRỌNG: DioClient TRƯỚC AuthRepository
  // Lý do: AuthRepository sẽ dùng DioClient
  sl.registerLazySingleton<DioClient>(
        () => DioClient(storage: sl()),
  );

  //Local data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(storage: sl()),
  );

  //Remote data sources (dùng DioClient đã register)
  sl.registerLazySingleton<AuthDataSource>(
        () => AuthRemoteDataSourceImpl(dio: sl<DioClient>()),
  );

  sl.registerLazySingleton<DestinationDataSource>(
        () => DestinationDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<ProvinceDataSource>(
        () => ProvinceDataSourceImpl(sl<AuthLocalDataSource>(), dioClient: sl()),
  );

  sl.registerLazySingleton<HotelDataSource>(
        () => HotelDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<TourRemoteDataSource>(
        () => TourRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<BookingDataSource>(
        () => BookingDataSourceImpl(client: sl()),
  );

  // Repositories (sau khi data sources sẵn sàng)
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

  sl.registerLazySingleton<HotelRepository>(
        () => HotelRepositoryImpl(
      hotelDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localStorage: sl(),
    ),
  );

  sl.registerLazySingleton<TourRepository>(
        () => TourRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<BookingRepository>(
        () => BookingRepositoryImpl(
      bookingDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<PaymentRepository>(
        () => PaymentRepositoryImpl(
      dioClient: sl(),
      networkInfo: sl(),
    ),
  );

  // Thêm TokenRefreshInterceptor SAU khi AuthRepository ready
  sl<DioClient>().addRefreshTokenInterceptor(
    authRepository: sl<AuthRepository>(),
    localDataSource: sl<AuthLocalDataSource>(),
  );

  //Use cases
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));
  sl.registerLazySingleton(() => FacebookLoginUseCase(sl()));

  sl.registerLazySingleton(() => GetAllDestinationFeaturedUseCase(sl()));
  sl.registerLazySingleton(() => GetAllDestinationsUseCase(sl()));
  sl.registerLazySingleton(() => FilterDestinationsByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetDetailDestinationUseCase(sl()));

  sl.registerLazySingleton(() => GetAllProvinceUseCase(sl()));
  sl.registerLazySingleton(() => ProvinceDetailUseCase(sl()));
  sl.registerLazySingleton(() => AddProvinceUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProvinceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProvinceUseCase(sl()));

  sl.registerLazySingleton(() => HotelDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetHotelsUseCase(sl()));

  sl.registerLazySingleton<GetTourDetailUseCase>(
        () => GetTourDetailUseCase(sl()),
  );

  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSettingsUseCase(sl()));
  sl.registerLazySingleton(() => GetLevelUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  sl.registerLazySingleton(() => CreateBookingUseCase(sl()));
  sl.registerLazySingleton(() => ProcessPaymentUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmCashBookingUseCase(sl()));

  sl.registerLazySingleton<ImageUploadService>(
        () => ImageUploadService(sl()),
  );

  //BLOCs (cuối cùng)
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

  // Chat
  sl.registerLazySingleton(() => ChatRepository(sl()));
  sl.registerFactory(() => ChatBloc(sl()));

  sl.registerFactory(
        () => DestinationBloc(
      destinationFeaturedUseCase: sl(),
      getAllDestinationUseCase: sl(),
      filterByCategoryUseCase: sl(),
      getDetailDestinationUseCase: sl(),
    ),
  );

  sl.registerFactory(
        () => ProvinceBloc(
      getAllProvinceUseCase: sl(),
      addProvinceUseCase: sl(),
      updateProvinceUseCase: sl(),
      deleteProvinceUseCase: sl(),
    ),
  );

  sl.registerFactory(
        () => ProvinceDetailBloc(provinceDetailUseCase: sl()),
  );

  sl.registerFactory(
        () => HotelDetailBloc(hotelDetailUseCase: sl()),
  );

  sl.registerFactory(
        () => HotelBloc(getHotelsUseCase: sl()),
  );

  sl.registerFactory(
        () => ProfileBloc(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      changePasswordUseCase: sl(),
      getSettingsUseCase: sl(),
      updateSettingsUseCase: sl(),
      getLevelUseCase: sl(),
      deleteAccountUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  sl.registerFactory(
        () => TourBloc(sl()),
  );

  sl.registerFactory(
        () => BookingBloc(createBookingUseCase: sl()),
  );

  sl.registerFactory(
        () => PaymentBloc(
      processPaymentUseCase: sl(),
      confirmCashBookingUseCase: sl(),
    ),
  );
}