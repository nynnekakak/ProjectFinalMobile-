import 'package:flutter/material.dart';
import 'package:moneyboys/Modules/Home/Home_loading.dart';
import 'package:moneyboys/Modules/Home/home_Screen.dart';
import 'package:moneyboys/Modules/SignIn/View/Signin_screen.dart';
import 'package:moneyboys/Modules/SignUp/View/signup_screen.dart';
import 'package:moneyboys/Modules/flash_screen.dart';
import 'package:moneyboys/app/config/route-path.dart';

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
