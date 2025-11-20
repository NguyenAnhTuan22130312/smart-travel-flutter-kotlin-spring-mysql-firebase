import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:smart_travel/data/data_sources/local/auth_local_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/destination_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/hotel_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/province_data_source.dart';
import 'package:smart_travel/data/repositories/auth_repository_impl.dart';
import 'package:smart_travel/data/repositories/destination_repository_impl.dart';
import 'package:smart_travel/data/repositories/hotel_repository_impl.dart';
import 'package:smart_travel/data/repositories/province_repository_impl.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';
import 'package:smart_travel/domain/repositories/hotel_repository.dart';
import 'package:smart_travel/domain/repositories/province_repository.dart';
import 'package:smart_travel/domain/usecases/auth/facebook_login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/forgot_password_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/google_login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/register_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/filter_destinations_by_category_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_featured_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_detail_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/hotel/hotel_detail_use_case.dart';
import 'package:smart_travel/domain/usecases/province/get_all_province_use_case.dart';
import 'package:smart_travel/domain/usecases/province/province_detail_use_case.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotail_detail_bloc.dart';
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

final sl = GetIt.instance;

Future<void> init() async {
  // --- BẮT ĐẦU: THÊM CÁC DỊCH VỤ BOOKING ---
  // Bloc
  sl.registerFactory(
    () => BookingBloc(createBookingUseCase: sl()), // Sửa dòng này
  );
  // Use cases
  sl.registerLazySingleton(() => CreateBookingUseCase(sl()));

  // Repository
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(bookingDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BookingDataSource>(
    () => BookingDataSourceImpl(client: sl()),
  );

  // Bloc
  sl.registerFactory(
    () => PaymentBloc(
      processPaymentUseCase: sl(),
      confirmCashBookingUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ProcessPaymentUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmCashBookingUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(dioClient: sl(), networkInfo: sl()),
  );

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

  //bloc destination
  sl.registerFactory(
    () => DestinationBloc(
      destinationFeaturedUseCase: sl(),
      getAllDestinationUseCase: sl(),
      filterByCategoryUseCase: sl(),
      getDetailDestinationUseCase: sl(),
    ),
  );

  //bloc province
  sl.registerFactory(() => ProvinceBloc(getAllProvinceUseCase: sl()));
  sl.registerFactory(() => ProvinceDetailBloc(provinceDetailUseCase: sl()));

  // --- THÊM BLOC HOTEL ---
  sl.registerFactory(() => HotelDetailBloc(hotelDetailUseCase: sl()));

  // Use cases
  // auth
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));
  sl.registerLazySingleton(() => FacebookLoginUseCase(sl()));

  //  destination
  sl.registerLazySingleton(() => GetAllDestinationFeaturedUseCase(sl()));
  sl.registerLazySingleton(() => GetAllDestinationsUseCase(sl()));
  sl.registerLazySingleton(() => FilterDestinationsByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetDetailDestinationUseCase(sl()));

  //  province
  sl.registerLazySingleton(() => GetAllProvinceUseCase(sl()));
  sl.registerLazySingleton(() => ProvinceDetailUseCase(sl()));

  // --- THÊM USE CASE HOTEL ---
  sl.registerLazySingleton(() => HotelDetailUseCase(sl()));

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
    () => ProvinceRepositoryImpl(provinceDataSource: sl(), networkInfo: sl()),
  );

  // --- THÊM REPO HOTEL ---
  sl.registerLazySingleton<HotelRepository>(
    () => HotelRepositoryImpl(hotelDataSource: sl(), networkInfo: sl()),
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
  // --- THÊM DATA SOURCE HOTEL ---
  sl.registerLazySingleton<HotelDataSource>(
        () => HotelDataSourceImpl(client: sl()),
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

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => DioClient(sl(), sl()));
}
