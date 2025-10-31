import 'package:flutter/material.dart';
import 'package:moneyboys/app/app_theme.dart';
import 'package:moneyboys/screens/Signin_screen.dart';
import 'package:moneyboys/screens/flash_screen.dart';
import 'package:moneyboys/screens/signup_screen.dart';
import 'package:moneyboys/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
      theme: AppTheme.darkAmber(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}
