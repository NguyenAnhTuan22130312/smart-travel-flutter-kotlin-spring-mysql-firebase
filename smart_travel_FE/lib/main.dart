import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_event.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_state.dart';
import 'package:smart_travel/presentation/blocs/province/provicne_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/province_bloc.dart';
import 'package:smart_travel/presentation/screens/booking/booking_screen.dart';
import 'package:smart_travel/presentation/screens/splash/splash_screen.dart';
import 'package:smart_travel/router/app_router.dart';
import 'package:smart_travel/router/route_names.dart';

import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize dependency injection
  await di.init();
  await Firebase.initializeApp();

  // Set status bar color to transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // For dark background
  ));

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          // Provide AuthBloc globally
          BlocProvider(
            create: (_) => di.sl<AuthBloc>(),
          ),
          BlocProvider(
            create: (_) => di.sl<DestinationBloc>(),
          ),
          BlocProvider(
            create: (_) => di.sl<ProvinceBloc>(),
          ),
          BlocProvider(
            create: (_) => di.sl<ProvinceDetailBloc>(),
          ),
          BlocProvider(
            create: (_) => di.sl<ProfileBloc>()..add(LoadSettings()),
          ),
        ],
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            // Update dark mode setting whenever any state with this info is emitted
            if (state is SettingsLoaded) {
              setState(() {
                _isDarkMode = state.settings.darkModeEnabled;
              });
            } else if (state is SettingsUpdateSuccess) {
              setState(() {
                _isDarkMode = state.settings.darkModeEnabled;
              });
            } else if (state is ProfileLoaded) {
              setState(() {
                _isDarkMode = state.user.darkModeEnabled;
              });
            }
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: RouteNames.splashScreen,
            // -----------------------
            title: 'Smart Travel',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF1E1E1E), // IntelliJ Darcula background
              cardColor: const Color(0xFF2B2B2B), // Card/surface color
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
                background: const Color(0xFF1E1E1E),
                surface: const Color(0xFF2B2B2B),
              ),
              useMaterial3: true,
            ),
            themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
          ),
        )
    );
  }
}