import 'package:flutter/material.dart';
<<<<<<< HEAD:lib/main.dart
import 'package:moneyboys/app/app_theme.dart';
import 'package:moneyboys/screens/Signin_screen.dart';
=======
import 'package:moneyboys/app/config/app_router.dart';
>>>>>>> b21945e2acd8064530cb3b884baf0090f1cd98bd:lib/app/config/app_widget.dart
import 'package:moneyboys/screens/flash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
<<<<<<< HEAD:lib/main.dart
      theme: AppTheme.darkAmber(),
      home: const HomeScreen(),
=======
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6F35A5)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
>>>>>>> b21945e2acd8064530cb3b884baf0090f1cd98bd:lib/app/config/app_widget.dart
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoute.onGenerateRoute,
    );
  }
}
