import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotail_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_bloc.dart';
import 'package:smart_travel/presentation/screens/auth/forgot_password_screen.dart';
import 'package:smart_travel/presentation/screens/auth/login_screen.dart';
import 'package:smart_travel/presentation/screens/auth/register_screen.dart';
import 'package:smart_travel/presentation/screens/destination/detail_destination_screen.dart';
import 'package:smart_travel/presentation/screens/explore/explore_screen.dart';
import 'package:smart_travel/presentation/screens/home/home_screen.dart';
import 'package:smart_travel/presentation/screens/hotel/detail_hotel_screen.dart';
import 'package:smart_travel/presentation/screens/profile/account_management_screen.dart';
import 'package:smart_travel/presentation/screens/profile/change_password_screen.dart';
import 'package:smart_travel/presentation/screens/profile/edit_profile_screen.dart';
import 'package:smart_travel/presentation/screens/profile/profile_screen.dart';
import 'package:smart_travel/presentation/screens/profile/settings_screen.dart';
import 'package:smart_travel/presentation/screens/profile/user_level_screen.dart';
import 'package:smart_travel/presentation/screens/province/province_detail_screen.dart';
import 'package:smart_travel/presentation/screens/splash/splash_screen.dart';
import 'package:smart_travel/router/route_names.dart';
import '../injection_container.dart' as di;

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.provinceDetail:
        return MaterialPageRoute(
          builder: (context) => ProvinceDetailScreen(),
          settings: settings,
        );
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
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
        return MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        );
      case RouteNames.editProfile:
        return MaterialPageRoute(
          builder: (context) => const EditProfileScreen(),
        );
      case RouteNames.changePassword:
        return MaterialPageRoute(
          builder: (context) => const ChangePasswordScreen(),
        );
      case RouteNames.settings:
        return MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
        );
      case RouteNames.accountManagement:
        return MaterialPageRoute(
          builder: (context) => const AccountManagementScreen(),
        );
      case RouteNames.userLevel:
        return MaterialPageRoute(
          builder: (context) => const UserLevelScreen(),
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
