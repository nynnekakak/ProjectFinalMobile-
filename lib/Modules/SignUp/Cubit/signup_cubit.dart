// lib/features/auth/cubit/sign_up_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyboys/Modules/SignUp/Cubit/signup_api.dart';
import 'package:moneyboys/Modules/SignUp/Cubit/signup_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final SignUpApiService _authApiService;

  SignUpCubit({SignUpApiService? authApiService})
    : _authApiService = authApiService ?? SignUpApiService(),
      super(SignUpInitial());

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    // Email phải có định dạng hợp lệ và đuôi hợp lệ
    final emailRegex = RegExp(
      r'^[\w-\.]+@(gmail\.com|yahoo\.com|hotmail\.com|outlook\.com)$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email (e.g. name@gmail.com)';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    // Mật khẩu >= 6 ký tự, có chữ hoa, chữ thường, và số
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{6,}$',
    );

    if (!passwordRegex.hasMatch(value)) {
      return 'Password must have uppercase, lowercase, number and be at least 6 characters';
    }
    return null;
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required bool agreeToTerms,
  }) async {
    if (!agreeToTerms) {
      emit(
        const SignUpValidationError(
          'Please agree to the processing of personal data',
        ),
      );
      return;
    }

    emit(SignUpLoading());

    try {
      final result = await _authApiService.signUp(
        email: email,
        password: password,
        name: name,
      );

      emit(
        SignUpSuccess(message: 'Sign up successful! Welcome ${result['name']}'),
      );
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('Email already exists')) {
        emit(const SignUpEmailExists());
      } else {
        emit(SignUpFailure(errorMessage));
      }
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      return await _authApiService.checkEmailExists(email);
    } catch (e) {
      return false;
    }
  }

  void reset() {
    emit(SignUpInitial());
  }
}
