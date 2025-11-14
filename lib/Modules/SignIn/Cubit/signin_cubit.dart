// lib/features/auth/cubit/sign_in_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyboys/Modules/SignIn/Cubit/signin_api.dart';
import 'package:moneyboys/Modules/SignIn/Cubit/signin_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInCubit extends Cubit<SignInState> {
  final SignInApiService _authApiService;

  SignInCubit({SignInApiService? authApiService})
    : _authApiService = authApiService ?? SignInApiService(),
      super(SignInInitial());

  /// Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    emit(SignInLoading());

    try {
      // Call API to sign in
      final result = await _authApiService.signIn(
        email: email,
        password: password,
      );

      final userId = result['id'];
      final userName = result['name'];

      // Save user ID to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      await prefs.setString('userName', userName);

      emit(SignInSuccess(userId: userId, userName: userName));
    } catch (e) {
      emit(SignInFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Check if user is already logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      return userId != null && userId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get saved user ID
  Future<String?> getSavedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userId');
    } catch (e) {
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('userName');
      emit(SignInInitial());
    } catch (e) {
      emit(SignInFailure('Failed to sign out'));
    }
  }

  /// Reset state to initial
  void reset() {
    emit(SignInInitial());
  }
}
