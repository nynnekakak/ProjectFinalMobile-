// lib/features/auth/signup/data/sign_up_api_service.dart

import 'dart:convert' show utf8;
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpApiService {
  final SupabaseClient _supabase;

  SignUpApiService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Hash password using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign up user with email, password and name
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Check if email already exists
      final existingUser = await _supabase
          .from('user')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception('Email already exists');
      }

      // Hash password and insert user
      final passwordHash = _hashPassword(password);

      final result = await _supabase
          .from('user')
          .insert({'email': email, 'password_hash': passwordHash, 'name': name})
          .select('id, name')
          .single();

      return {'id': result['id'].toString(), 'name': result['name'] ?? ''};
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique violation error code
        throw Exception('Email already exists');
      }
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      final result = await _supabase
          .from('user')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return result != null;
    } catch (e) {
      return false;
    }
  }
}
