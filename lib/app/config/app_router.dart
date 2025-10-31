import 'package:flutter/material.dart';
import 'package:moneyboys/app/config/route-path.dart';
import 'package:moneyboys/screens/Home_loading.dart';
import 'package:moneyboys/screens/flash_screen.dart';
import 'package:moneyboys/screens/home_screen.dart';
import 'package:moneyboys/screens/signin_screen.dart';
import 'package:moneyboys/screens/signup_screen.dart';

class AppRoute {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePath.flash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RoutePath.signIn:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case RoutePath.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case RoutePath.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RoutePath.homeloading:
        return MaterialPageRoute(builder: (_) => const HomeLoadingScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('404 - Page Not Found'))),
        );
    }
  }
}
