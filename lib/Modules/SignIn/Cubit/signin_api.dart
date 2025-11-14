// lib/features/auth/signin/data/sign_in_api_service.dart

import 'dart:convert' show utf8;
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInApiService {
  final SupabaseClient _supabase;

  SignInApiService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Hash password using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign in user with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Query user from database
      final user = await _supabase
          .from('user')
          .select('id, password_hash, name')
          .eq('email', email)
          .maybeSingle();

      // Check if user exists
      if (user == null) {
        throw Exception('User not found');
      }

      // Verify password
      final inputPasswordHash = _hashPassword(password);
      final storedPasswordHash = user['password_hash'];

      if (inputPasswordHash != storedPasswordHash) {
        throw Exception('Incorrect password');
      }

      // Return user data
      return {'id': user['id'].toString(), 'name': user['name'] ?? ''};
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
