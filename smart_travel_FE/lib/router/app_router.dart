import 'package:flutter/material.dart';
import 'package:smart_travel/presentation/screens/auth/forgot_password_screen.dart';
import 'package:smart_travel/presentation/screens/auth/login_screen.dart';
import 'package:smart_travel/presentation/screens/auth/register_screen.dart';
import 'package:smart_travel/presentation/screens/home/home_screen.dart';
import 'package:smart_travel/presentation/screens/splash/splash_screen.dart';
import 'package:smart_travel/router/route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteNames.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
        default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('404 - Page not found')),
          ),
        );
    }
  }
}