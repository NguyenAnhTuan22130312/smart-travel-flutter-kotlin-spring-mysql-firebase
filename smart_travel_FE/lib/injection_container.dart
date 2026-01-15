import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:smart_travel/core/services/image_upload_service.dart';
import 'package:smart_travel/data/data_sources/local/auth_local_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/audio_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/banner_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/destination_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/hotel_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/province_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/user_remote_datasource.dart';
import 'package:smart_travel/data/repositories/audio_repository_impl.dart';
import 'package:smart_travel/data/repositories/auth_repository_impl.dart';
import 'package:smart_travel/data/repositories/banner_repository_impl.dart';
import 'package:smart_travel/data/repositories/destination_repository_impl.dart';
import 'package:smart_travel/data/repositories/hotel_repository_impl.dart';
import 'package:smart_travel/data/repositories/province_repository_impl.dart';
import 'package:smart_travel/data/repositories/user_repository_impl.dart';
import 'package:smart_travel/domain/repositories/audio_repository.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';
import 'package:smart_travel/domain/repositories/banner_repository.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';
import 'package:smart_travel/domain/repositories/hotel_repository.dart';
import 'package:smart_travel/domain/repositories/province_repository.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';
import 'package:smart_travel/domain/usecases/audio/add_audio_use_case.dart';
import 'package:smart_travel/domain/usecases/audio/delete_audio_use_case.dart';
import 'package:smart_travel/domain/usecases/audio/edit_audio_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/facebook_login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/forgot_password_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/google_login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/login_use_case.dart';
import 'package:smart_travel/domain/usecases/auth/register_use_case.dart';
import 'package:smart_travel/domain/usecases/banner/create_banner_uc.dart';
import 'package:smart_travel/domain/usecases/banner/delete_banner_uc.dart';
import 'package:smart_travel/domain/usecases/banner/get_all_banner_use_case.dart';
import 'package:smart_travel/domain/usecases/banner/update_banner_uc.dart';
import 'package:smart_travel/domain/usecases/destination/CompleteVoiceUseCase.dart';
import 'package:smart_travel/domain/usecases/destination/add_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/delete_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/filter_destinations_by_category_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_featured_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_detail_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_weather_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/update_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/hotel/create_hotel_use_case.dart';
import 'package:smart_travel/domain/usecases/hotel/delete_hotel_use_case.dart';
import 'package:smart_travel/domain/usecases/hotel/get_hotels_use_case.dart';
import 'package:smart_travel/domain/usecases/hotel/hotel_detail_use_case.dart';
import 'package:smart_travel/domain/usecases/hotel/update_hotel_use_case.dart';
import 'package:smart_travel/domain/usecases/hotel/upload_hotel_images_use_case.dart';
import 'package:smart_travel/domain/usecases/province/add_province_use_case.dart';
import 'package:smart_travel/domain/usecases/province/delete_province_use_case.dart';
import 'package:smart_travel/domain/usecases/province/get_all_province_use_case.dart';
import 'package:smart_travel/domain/usecases/province/province_detail_use_case.dart';
import 'package:smart_travel/domain/usecases/province/update_province_use_case.dart';
import 'package:smart_travel/domain/usecases/tour/delete_image_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/set_primary_tour_image_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/upload_image_usecase.dart';
import 'package:smart_travel/domain/usecases/user/get_profile_usecase.dart';
import 'package:smart_travel/domain/usecases/user/update_profile_usecase.dart';
import 'package:smart_travel/domain/usecases/user/change_password_usecase.dart';
import 'package:smart_travel/domain/usecases/user/get_settings_usecase.dart';
import 'package:smart_travel/domain/usecases/user/update_settings_usecase.dart';
import 'package:smart_travel/domain/usecases/user/get_level_usecase.dart';
import 'package:smart_travel/domain/usecases/user/delete_account_usecase.dart';
import 'package:smart_travel/domain/usecases/user/logout_usecase.dart';
import 'package:smart_travel/domain/usecases/user/get_user_list.dart';
import 'package:smart_travel/domain/usecases/user/create_user_usecase.dart';
import 'package:smart_travel/domain/usecases/user/update_user_usecase.dart';
import 'package:smart_travel/domain/usecases/user/lock_user_usecase.dart';
import 'package:smart_travel/domain/usecases/user/unlock_user_usecase.dart';
import 'package:smart_travel/presentation/blocs/admin_audio/audio_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_invoice/admin_invoice_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_invoice/admin_invoice_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_voucher/voucher_bloc.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_bloc.dart';
import 'package:smart_travel/presentation/blocs/banner/banner_bloc.dart';
import 'package:smart_travel/presentation/blocs/chat/chat_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/favorite/favorite_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_bloc.dart';
import 'package:smart_travel/presentation/blocs/invoice/cancel_bloc.dart';
import 'package:smart_travel/presentation/blocs/invoice/detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/invoice/invoice_bloc.dart';
import 'package:smart_travel/presentation/blocs/invoice/refund_bloc.dart';
import 'package:smart_travel/presentation/blocs/invoice/review_bloc.dart';
import 'package:smart_travel/presentation/blocs/invoice/search_bloc.dart';
import 'package:smart_travel/presentation/blocs/invoice/transaction_bloc.dart';
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
import 'package:smart_travel/presentation/blocs/review/reviewhtd_bloc.dart';
import 'package:smart_travel/presentation/blocs/review/submit_review_bloc.dart';
import 'package:smart_travel/presentation/blocs/weather/weather_bloc.dart';
import 'core/network/network_info.dart';
import 'data/data_sources/remote/auth_remote_datasource.dart';
import 'package:smart_travel/data/data_sources/remote/booking_data_source.dart';
import 'package:smart_travel/data/repositories/booking_repository_impl.dart';
import 'package:smart_travel/domain/repositories/booking_repository.dart';
import 'package:smart_travel/domain/usecases/booking/create_booking_usecase.dart';
import 'package:smart_travel/data/data_sources/remote/tour_remote_data_source.dart';
import 'package:smart_travel/data/repositories/tour_repository_impl.dart';
import 'package:smart_travel/domain/repositories/tour_repository.dart';
import 'package:smart_travel/presentation/blocs/tour/tour_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/tour/tour_bloc.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_bloc.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_detail_bloc.dart';
import 'package:smart_travel/domain/usecases/tour/get_tour_detail_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/filter_tour_usecase.dart';
import 'package:smart_travel/data/data_sources/remote/statistics_data_source.dart';
import 'package:smart_travel/data/repositories/statistics_repository_impl.dart';
import 'package:smart_travel/domain/repositories/statistics_repository.dart';
import 'package:smart_travel/presentation/blocs/statistics/statistics_bloc.dart';
import 'package:smart_travel/domain/usecases/tour/get_admin_tour_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/get_admin_detail_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/create_tour_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/delete_tour_usecase.dart';
import 'package:smart_travel/domain/usecases/tour/update_tour_usecase.dart';

import 'data/data_sources/remote/invoice_remote_data_source.dart';
import 'data/data_sources/remote/review_remote_data_source.dart';
import 'data/data_sources/remote/reviewhtd_remote_data_source.dart';
import 'data/data_sources/remote/voucher_data_source.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'data/repositories/invoice_repository_impl.dart';
import 'data/repositories/review_repository_impl.dart';
import 'data/repositories/reviewhtd_repository_impl.dart';

import 'data/repositories/voucher_repository_impl.dart';
import 'domain/repositories/comparison_repository.dart';
import 'domain/repositories/review_repository.dart';
import 'domain/repositories/reviewhtd_repository.dart';
import 'domain/repositories/voucher_repository.dart';
import 'domain/usecases/invoice/admin_approve_refund_usecase.dart';
import 'domain/usecases/invoice/admin_cancel_order_usecase.dart';
import 'domain/usecases/invoice/admin_check_in_usecase.dart';
import 'domain/usecases/invoice/admin_check_out_usecase.dart';
import 'domain/usecases/invoice/cancel_booking_usecase.dart';
import 'domain/usecases/invoice/get_active_invoices_usecase.dart';
import 'domain/repositories/invoice_repository.dart';
import 'domain/usecases/invoice/get_admin_invoice_detail_usecase.dart';
import 'domain/usecases/invoice/get_admin_invoices_usecase.dart';
import 'domain/usecases/invoice/get_invoice_detail_usecase.dart';
import 'domain/usecases/invoice/get_refunded_invoices_usecase.dart';
import 'domain/usecases/invoice/get_reviewable_invoices_usecase.dart';
import 'domain/usecases/invoice/get_transaction_history_usecase.dart';
import 'domain/usecases/invoice/search_active_invoices_usecase.dart';
import 'domain/usecases/review/get_reviewhtd_usecase.dart';
import 'domain/usecases/review/submit_review_usecase.dart';
import 'domain/usecases/voucher/create_voucher_uc.dart';
import 'domain/usecases/voucher/delete_voucher_uc.dart';
import 'domain/usecases/voucher/get_all_voucher_uc.dart';
import 'domain/usecases/voucher/update_voucher_uc.dart';
import 'package:smart_travel/presentation/blocs/comparison/comparison_bloc.dart';


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
  sl.registerLazySingleton<DioClient>(() => DioClient(storage: sl()));

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
  sl.registerLazySingleton<BannerDataSource>(
    () => BannerDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<StatisticsRemoteDataSource>(
    () => StatisticsRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton(() => FavoriteBloc());

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

  sl.registerLazySingleton(() => ComparisonRepository(sl()));

  // 2. Bloc
  // Bloc này cần 3 cái repo: ComparisonRepo, TourRepo, HotelRepo
  // Đảm bảo TourRepository và HotelRepository ĐÃ ĐƯỢC đăng ký ở đâu đó phía trên rồi nhé
  sl.registerFactory(() => ComparisonBloc(
    comparisonRepository: sl(),
    tourRepository: sl(),
    hotelRepository: sl(),
  ));

  sl.registerLazySingleton<ProvinceRepository>(
    () => ProvinceRepositoryImpl(provinceDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<HotelRepository>(
    () => HotelRepositoryImpl(hotelDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl(), localStorage: sl()),
  );

  sl.registerLazySingleton<TourRepository>(() => TourRepositoryImpl(sl()));

  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(bookingDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<BannerRepository>(
    () => BannerRepositoryImpl(bannerDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => FilterToursUseCase(sl()));
  // auth
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(dioClient: sl(), networkInfo: sl()),
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
  sl.registerLazySingleton(() => AddDestinationUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDestinationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDestinationUseCase(sl()));
  sl.registerLazySingleton(() => GetWeatherUseCase(sl()));
  sl.registerLazySingleton(() => CompleteVoiceUseCase(sl()));

  sl.registerLazySingleton(() => GetAllProvinceUseCase(sl()));
  sl.registerLazySingleton(() => ProvinceDetailUseCase(sl()));
  sl.registerLazySingleton(() => AddProvinceUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProvinceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProvinceUseCase(sl()));

  // --- THÊM USE CASE HOTEL ---
  sl.registerLazySingleton(() => HotelDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetHotelsUseCase(sl()));
  sl.registerLazySingleton(() => CreateHotelUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHotelUseCase(sl()));
  sl.registerLazySingleton(() => DeleteHotelUseCase(sl()));
  sl.registerLazySingleton(() => UploadHotelImagesUseCase(sl()));

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
  sl.registerLazySingleton(() => GetUserList(repository: sl()));
  sl.registerLazySingleton(() => CreateUser(repository: sl()));
  sl.registerLazySingleton(() => UpdateUser(sl()));
  sl.registerLazySingleton(() => LockUser(sl()));
  sl.registerLazySingleton(() => UnlockUser(sl()));

  sl.registerLazySingleton(() => CreateBookingUseCase(sl()));
  sl.registerLazySingleton(() => ProcessPaymentUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmCashBookingUseCase(sl()));

  //uc banner
  sl.registerLazySingleton(() => GetAllBannerUseCase(sl()));
  sl.registerLazySingleton(() => CreateBannerUc(sl()));
  sl.registerLazySingleton(() => UpdateBannerUc(sl()));
  sl.registerLazySingleton(() => DeleteBannerUc(sl()));

  // VOUCHERS

  sl.registerFactory(
    () => VoucherBloc(
      getAllVoucherUc: sl(),
      createVoucherUc: sl(),
      updateVoucherUc: sl(),
      deleteVoucherUc: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetAllVoucherUc(sl()));
  sl.registerLazySingleton(() => CreateVoucherUc(sl()));
  sl.registerLazySingleton(() => UpdateVoucherUc(sl()));
  sl.registerLazySingleton(() => DeleteVoucherUc(sl()));

  sl.registerLazySingleton<VoucherRepository>(
    () => VoucherRepositoryImpl(voucherDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<VoucherDataSource>(
    () => VoucherDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<ImageUploadService>(() => ImageUploadService(sl()));

  //BLOCs
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
      addDestinationUseCase: sl(),
      updateDestinationUseCase: sl(),
      deleteDestinationUseCase: sl(),
      getWeatherUseCase: sl(),
      completeVoiceUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => DestinationDetailBloc(getDetailDestinationUseCase: sl()),
  );

  // ---  BLOC WEATHER ---
  sl.registerFactory(() => WeatherBloc(getWeatherUseCase: sl()));

  sl.registerFactory(
    () => ProvinceBloc(
      getAllProvinceUseCase: sl(),
      addProvinceUseCase: sl(),
      updateProvinceUseCase: sl(),
      deleteProvinceUseCase: sl(),
    ),
  );

  sl.registerFactory(() => ProvinceDetailBloc(provinceDetailUseCase: sl()));

  // HotelBloc phải tiêm đủ 4 tham số
  sl.registerFactory(
    () => HotelBloc(
      getHotelsUseCase: sl(),
      createHotelUseCase: sl(),
      updateHotelUseCase: sl(),
      deleteHotelUseCase: sl(),
      uploadHotelImagesUseCase: sl(),
    ),
  );

  // ---  BLOC HOTEL ---
  sl.registerFactory(() => HotelDetailBloc(hotelDetailUseCase: sl()));

  // ---  BLOC BANNER ---
  sl.registerFactory(
    () => BannerBloc(
      allBannerUseCase: sl(),
      createBannerUseCase: sl(),
      deleteBannerUseCase: sl(),
      updateBannerUseCase: sl(),
    ),
  );
  // --- AUDIO ---
  // Đăng ký Data Source
  sl.registerLazySingleton<AudioDataSource>(
        () => AudioDataSourceImpl(dioClient: sl()),
  );

  // Đăng ký Repository
  sl.registerLazySingleton<AudioRepository>(
        () => AudioRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // --- AUDIO USE CASES ---
  sl.registerLazySingleton(() => AddAudioUseCase(sl()));
  sl.registerLazySingleton(() => EditAudioUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAudioUseCase(sl()));

  // Bloc audio
  // ---  BLOC ADMIN AUDIO ---
  sl.registerFactory(
    () => AudioBloc(
      updateDestinationUseCase: sl(),
      getAllDestinationsUseCase: sl(),
      addAudioUseCase: sl(),
      editAudioUseCase: sl(),
      deleteAudioUseCase: sl(),
    ),
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

  //Bloc tour
  sl.registerFactory(() => TourBloc(sl()));
  sl.registerFactory(() => TourDetailBloc(sl()));

  // --- Usecases
  sl.registerLazySingleton(() => GetAdminTours(sl()));
  sl.registerLazySingleton(() => GetAdminTourDetailUseCase(sl()));
  sl.registerLazySingleton(() => CreateAdminTourUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAdminTourUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAdminTourUseCase(sl()));
  sl.registerLazySingleton(() => SetPrimaryTourImageUseCase(sl()));
  sl.registerLazySingleton(() => UploadTourImageUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTourImageUseCase(sl()));

  // --- Blocs
  sl.registerFactory(
    () => AdminTourBloc(
      getAdminTours: sl(),
      createAdminTour: sl(),
      deleteAdminTour: sl(),
      uploadTourImage: sl(),
      deleteTourImage: sl(),
      setPrimaryTourImage: sl(),
    ),
  );

  sl.registerFactory(
    () => AdminTourDetailBloc(
      sl<GetAdminTourDetailUseCase>(),
      sl<UpdateAdminTourUseCase>(),
      sl<SetPrimaryTourImageUseCase>(),
      sl<DeleteTourImageUseCase>(),
    ),
  );

  sl.registerFactory(
    () => AdminUserBloc(
      getUserList: sl(),
      createUser: sl(),
      updateUser: sl(),
      lockUser: sl(),
      unlockUser: sl(),
    ),
  );

  sl.registerFactory(() => BookingBloc(createBookingUseCase: sl()));

  sl.registerFactory(
    () => PaymentBloc(
      processPaymentUseCase: sl(),
      confirmCashBookingUseCase: sl(),
    ),
  );

  // ==================== INVOICE ====================
  sl.registerLazySingleton<InvoiceRemoteDataSource>(
    () => InvoiceRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<InvoiceRepository>(
    () => InvoiceRepositoryImpl(sl<InvoiceRemoteDataSource>()),
  );

  // UseCase
  sl.registerFactory<GetActiveInvoicesUseCase>(
    () => GetActiveInvoicesUseCase(sl<InvoiceRepository>()),
  );

  // Bloc vẫn factory
  sl.registerFactory<InvoiceBloc>(
    () => InvoiceBloc(sl<GetActiveInvoicesUseCase>()),
  );

  // Transaction History UseCase
  sl.registerLazySingleton<GetTransactionHistoryUseCase>(
    () => GetTransactionHistoryUseCase(sl<InvoiceRepository>()),
  );

  // Transaction Bloc
  sl.registerFactory<TransactionBloc>(
    () => TransactionBloc(sl<GetTransactionHistoryUseCase>()),
  );

  // Refund UseCase
  sl.registerLazySingleton<GetRefundedInvoicesUseCase>(
    () => GetRefundedInvoicesUseCase(sl<InvoiceRepository>()),
  );

  // Refund Bloc
  sl.registerFactory<RefundBloc>(
    () => RefundBloc(sl<GetRefundedInvoicesUseCase>()),
  );

  // Review UseCase
  sl.registerLazySingleton<GetReviewableInvoicesUseCase>(
    () => GetReviewableInvoicesUseCase(sl<InvoiceRepository>()),
  );

  // Review Bloc
  sl.registerFactory<ReviewBloc>(
    () => ReviewBloc(sl<GetReviewableInvoicesUseCase>()),
  );

  // Search UseCase
  sl.registerLazySingleton<SearchActiveInvoicesUseCase>(
    () => SearchActiveInvoicesUseCase(sl<InvoiceRepository>()),
  );

  // Search Bloc
  sl.registerFactory<SearchBloc>(
    () => SearchBloc(sl<SearchActiveInvoicesUseCase>()),
  );

  // Cancel UseCase
  sl.registerLazySingleton<CancelBookingUseCase>(
    () => CancelBookingUseCase(sl<InvoiceRepository>()),
  );

  // Cancel Bloc
  sl.registerFactory<CancelBloc>(() => CancelBloc(sl<CancelBookingUseCase>()));

  sl.registerLazySingleton<GetInvoiceDetailUseCase>(
    () => GetInvoiceDetailUseCase(sl<InvoiceRepository>()),
  );

  sl.registerFactory<DetailBloc>(
    () => DetailBloc(sl<GetInvoiceDetailUseCase>()),
  );
  sl.registerFactory(() => StatisticsBloc(repository: sl()));

  // Review DataSource
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(sl<DioClient>()),
  );

  // Review Repository
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl<ReviewRemoteDataSource>()),
  );

  // Submit Review UseCase
  sl.registerLazySingleton<SubmitReviewUseCase>(
    () => SubmitReviewUseCase(sl<ReviewRepository>()),
  );

  // Submit Review Bloc
  sl.registerFactory<SubmitReviewBloc>(
    () => SubmitReviewBloc(sl<SubmitReviewUseCase>()),
  );

  // ReviewHtd Remote DataSource
  sl.registerLazySingleton<ReviewHtdRemoteDataSource>(
    () => ReviewHtdRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  // ReviewHtd Repository
  sl.registerLazySingleton<ReviewHtdRepository>(
    () => ReviewHtdRepositoryImpl(sl<ReviewHtdRemoteDataSource>()),
  );

  // Get ReviewHtd UseCase
  sl.registerLazySingleton<GetReviewHtdUseCase>(
    () => GetReviewHtdUseCase(sl<ReviewHtdRepository>()),
  );

  // ReviewHtd Bloc
  sl.registerFactory<ReviewHtdBloc>(
    () => ReviewHtdBloc(sl<GetReviewHtdUseCase>()),
  );

  sl.registerLazySingleton<GetAdminInvoicesUseCase>(
    () => GetAdminInvoicesUseCase(sl<InvoiceRepository>()),
  );

  sl.registerFactory<AdminInvoiceBloc>(
    () => AdminInvoiceBloc(sl<GetAdminInvoicesUseCase>()),
  );

  sl.registerLazySingleton<GetAdminInvoiceDetailUseCase>(
    () => GetAdminInvoiceDetailUseCase(sl<InvoiceRepository>()),
  );

  sl.registerFactory<AdminInvoiceDetailBloc>(
    () => AdminInvoiceDetailBloc(sl<GetAdminInvoiceDetailUseCase>()),
  );

  sl.registerLazySingleton<AdminCheckInUseCase>(
    () => AdminCheckInUseCase(sl<InvoiceRepository>()),
  );

  sl.registerLazySingleton<AdminCheckOutUseCase>(
    () => AdminCheckOutUseCase(sl<InvoiceRepository>()),
  );

  sl.registerLazySingleton<AdminApproveRefundUseCase>(
    () => AdminApproveRefundUseCase(sl<InvoiceRepository>()),
  );

  sl.registerLazySingleton<AdminCancelOrderUseCase>(
    () => AdminCancelOrderUseCase(sl<InvoiceRepository>()),
  );
}
