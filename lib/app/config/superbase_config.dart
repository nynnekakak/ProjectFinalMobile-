import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Thông tin project Supabase
  static const String supabaseUrl = 'https://dugyhamegxvpdmwywsui.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1Z3loYW1lZ3h2cGRtd3l3c3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI2MjkzMjMsImV4cCI6MjA3ODIwNTMyM30.NSMGAbqA3wilCIkAIYwI5h5fTElaL-4I8id10mnRnYA';

  // Hàm khởi tạo Supabase
  static Future<void> init() async {
    try {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      print('Supabase initialized successfully!');
    } catch (e) {
      print('Supabase initialization failed: $e');
    }
  }
}
