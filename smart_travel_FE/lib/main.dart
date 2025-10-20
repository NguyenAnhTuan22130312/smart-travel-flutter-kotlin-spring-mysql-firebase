import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/province_bloc.dart';
import 'package:smart_travel/presentation/screens/booking/booking_screen.dart';
import 'package:smart_travel/router/app_router.dart';
import 'package:smart_travel/router/route_names.dart';

import 'injection_container.dart' as di;

void main() async {
  // Initialize dependency injection
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,

          // --- SỬA ĐỔI ĐỂ TEST ---

          // 1. Comment code route cũ của bạn
          // onGenerateRoute: AppRouter.generateRoute,
          // initialRoute: RouteNames.splashScreen,

          // 2. Thêm dòng này để chạy thẳng vào BookingScreen
          home: BookingScreen(),

          // -----------------------

          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
        )
    );
  }
}