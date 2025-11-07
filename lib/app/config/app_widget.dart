import 'package:flutter/material.dart';

import 'package:moneyboys/app/app_theme.dart';
import 'package:moneyboys/app/config/app_router.dart';
import 'package:moneyboys/app/route.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkAmber(),
      home: const Routes(),
      onGenerateRoute: AppRoute.onGenerateRoute,
    );
  }
}
