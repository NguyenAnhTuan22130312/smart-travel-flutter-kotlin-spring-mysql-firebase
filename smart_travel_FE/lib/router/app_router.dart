import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_bloc.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_event.dart';
import 'package:smart_travel/presentation/blocs/admin_audio/audio_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_audio/audio_event.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_bloc.dart';
import 'package:smart_travel/presentation/screens/admin/admin_dashboard.dart';
import 'package:smart_travel/presentation/screens/admin/audio/admin_audio_screen.dart';
import 'package:smart_travel/presentation/screens/admin/banner/banner_management_screen.dart';
import 'package:smart_travel/presentation/screens/admin/hotel/hotel_management_screen.dart';
import 'package:smart_travel/presentation/screens/admin/destination/destination_management_screen.dart';
import 'package:smart_travel/presentation/screens/admin/province/province_mgt.dart';
import 'package:smart_travel/presentation/screens/admin/user/user_mgt.dart';
import 'package:smart_travel/presentation/screens/admin/tour/tour_mgt.dart';
import 'package:smart_travel/presentation/screens/auth/forgot_password_screen.dart';
import 'package:smart_travel/presentation/screens/auth/login_screen.dart';
import 'package:smart_travel/presentation/screens/auth/register_screen.dart';
import 'package:smart_travel/presentation/screens/chat/group_chat_screen.dart';
import 'package:smart_travel/presentation/screens/destination/detail_destination_screen.dart';
import 'package:smart_travel/presentation/screens/explore/explore_screen.dart';
import 'package:smart_travel/presentation/screens/home/home_screen.dart';
import 'package:smart_travel/presentation/screens/hotel/detail_hotel_screen.dart';
import 'package:smart_travel/presentation/screens/hotel/hotel_list_screen.dart';
import 'package:smart_travel/presentation/screens/profile/account_management_screen.dart';
import 'package:smart_travel/presentation/screens/profile/change_password_screen.dart';
import 'package:smart_travel/presentation/screens/profile/edit_profile_screen.dart';
import 'package:smart_travel/presentation/screens/profile/profile_screen.dart';
import 'package:smart_travel/presentation/screens/profile/settings_screen.dart';
import 'package:smart_travel/presentation/screens/profile/user_level_screen.dart';
import 'package:smart_travel/presentation/screens/province/province_detail_screen.dart';
import 'package:smart_travel/presentation/screens/splash/splash_screen.dart';
import 'package:smart_travel/router/route_names.dart';
import 'package:smart_travel/presentation/screens/tour/tour_detail_screen.dart';
import '../injection_container.dart' as di;
import '../presentation/blocs/admin_invoice/admin_invoice_bloc.dart';
import '../presentation/blocs/admin_voucher/voucher_bloc.dart';
import '../presentation/blocs/admin_voucher/voucher_event.dart';
import '../presentation/screens/admin/invoice/admin_invoice_screen.dart';
import '../presentation/screens/invoice/my_invoices_screen.dart';
import 'package:smart_travel/presentation/screens/admin/voucher/voucher_management_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      ///ADMIN
      case RouteNames.dashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case RouteNames.adminProvinces:
        return MaterialPageRoute(
          builder: (_) => const ProvinceManagementScreen(),
        );
      case RouteNames.adminHotels:
        return MaterialPageRoute(
          builder: (_) => const HotelManagementScreen(),
        );
      case RouteNames.adminUsers:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (_) => di.sl<AdminUserBloc>(),
                child: const UserManagementScreen(),
              ),
        );
        /// Tour
      case RouteNames.adminTours:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => di.sl<AdminTourBloc>()),
              BlocProvider(create: (_) => di.sl<AdminTourDetailBloc>()),
            ],
            child: const AdminTourManagementScreen(),
          ),
        );
      case RouteNames.adminInvoices:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<AdminInvoiceBloc>()..add(LoadAdminInvoices()),
            child: const AdminInvoiceScreen(),
          ),
        );
      case RouteNames.adminAudio:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<AudioBloc>()..add(LoadAudioDestinations()),
            child: const AdminAudioScreen(),
          ),
        );
    /// USER
      case RouteNames.adminBanner:
        return MaterialPageRoute(
          builder: (_) => const BannerManagementScreen(),
        );

      /// USER
      case RouteNames.adminDestination:
        return MaterialPageRoute(
          builder: (_) => const DestinationManagementScreen(),
        );

      case RouteNames.adminVoucher:
        return MaterialPageRoute(
          // Vì bên trong VoucherManagementScreen bạn đã bọc BlocProvider rồi
          // nên ở đây chỉ cần gọi màn hình là được.
          builder: (_) => BlocProvider(
            create: (_) => di.sl<VoucherBloc>()..add(LoadAllVoucher()),
            child: const VoucherManagementScreen(),
          ),
        );

      case RouteNames.provinceDetail:
        return MaterialPageRoute(
          builder: (context) => ProvinceDetailScreen(),
          settings: settings,
        );
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteNames.explore:
        return MaterialPageRoute(builder: (_) => const ExploreScreen());
      case RouteNames.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case RouteNames.destinationDetail:
        return MaterialPageRoute(
          builder: (context) => DetailDestinationScreen(),
          settings: settings,
        );
      // Hotel
      case RouteNames.hotelList:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (_) => di.sl<HotelBloc>(),
                child: const HotelListScreen(),
              ),
          settings: settings,
        );
      case RouteNames.hotelDetail:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (_) => di.sl<HotelDetailBloc>(),
                child: const DetailHotelScreen(),
              ),
          settings: settings,
        );
      // Profile routes
      case RouteNames.profile:
        return MaterialPageRoute(builder: (context) => const ProfileScreen());
      case RouteNames.editProfile:
        return MaterialPageRoute(
          builder: (context) => const EditProfileScreen(),
        );
      case RouteNames.changePassword:
        return MaterialPageRoute(
          builder: (context) => const ChangePasswordScreen(),
        );
      case RouteNames.settings:
        return MaterialPageRoute(builder: (context) => const SettingsScreen());
      case RouteNames.accountManagement:
        return MaterialPageRoute(
          builder: (context) => const AccountManagementScreen(),
        );
      case RouteNames.userLevel:
        return MaterialPageRoute(builder: (context) => const UserLevelScreen());
      case RouteNames.tourDetail:
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => TourDetailScreen(tourId: id),
          settings: settings,
        );
      case RouteNames.myInvoices:
        return MaterialPageRoute(
          builder: (_) => const MyInvoicesScreen(),
        );
      case RouteNames.myFriend:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => GroupChatScreen(
            groupId: args['groupId'],
            currentUserId: args['userId'],
            currentUserName: args['userName'],
            currentUserAvatar: args['avatar'],
          ),
        );

      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('404 - Page not found')),
              ),
        );
    }
  }
}
