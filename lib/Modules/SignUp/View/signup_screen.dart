import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyboys/Modules/SignIn/View/Signin_screen.dart';
import 'package:moneyboys/Modules/SignUp/Cubit/signup_cubit.dart';
import 'package:moneyboys/Modules/SignUp/Cubit/signup_state.dart';
import 'package:moneyboys/Shared/widgets/custom_scaffold.dart';
import 'package:moneyboys/app/config/route-path.dart';
import 'package:moneyboys/data/services/auth_service.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formSignupKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _agreePersonalData = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!_formSignupKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    context.read<SignUpCubit>().signUp(
      email: email,
      password: password,
      name: name,
      agreeToTerms: _agreePersonalData,
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final user = await AuthService.signInWithGoogle();
    if (user != null) {
      Navigator.pushReplacementNamed(context, RoutePath.home);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    final user = await AuthService.signInWithFacebook();
    if (user != null) {
      Navigator.pushReplacementNamed(context, RoutePath.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (e) => const SignInScreen()),
          );
        } else if (state is SignUpEmailExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email already exists'),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (state is SignUpFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to register: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is SignUpValidationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      child: AppScaffold(
        title: "MoneyBoys",
        logoPath: 'assets/images/logo.jpg',
        showBackButton: false,
        body: Container(
          margin: const EdgeInsets.all(16),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formSignupKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    validator: context.read<SignUpCubit>().validateName,
                    decoration: _inputDecoration('Full Name'),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    validator: context.read<SignUpCubit>().validateEmail,
                    decoration: _inputDecoration('Email'),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    validator: context.read<SignUpCubit>().validatePassword,
                    decoration: _inputDecoration('Password').copyWith(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Checkbox
                  Row(
                    children: [
                      Checkbox(
                        activeColor: const Color(0xFFFFD700),
                        value: _agreePersonalData,
                        onChanged: (val) {
                          setState(() => _agreePersonalData = val!);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'I agree to the processing of personal data',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Button
                  BlocBuilder<SignUpCubit, SignUpState>(
                    builder: (context, state) {
                      final isLoading = state is SignUpLoading;

                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'or sign up with',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Social Icons with Firebase Auth
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.facebook,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: _handleFacebookSignIn,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.g_mobiledata,
                          color: Colors.white,
                          size: 36,
                        ),
                        onPressed: _handleGoogleSignIn,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Navigate to Sign In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            RoutePath.signIn,
                          );
                        },
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF2B2B2B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFFD700)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
