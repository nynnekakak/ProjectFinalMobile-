import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:moneyboys/app/config/app_widget.dart';
import 'package:moneyboys/app/config/firebase_options.dart';
import 'package:moneyboys/app/config/superbase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Khởi tạo Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}
