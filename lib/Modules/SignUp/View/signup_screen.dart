import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyboys/Modules/SignIn/View/Signin_screen.dart';
import 'package:moneyboys/Modules/SignUp/Cubit/signup_cubit.dart';
import 'package:moneyboys/Modules/SignUp/Cubit/signup_state.dart';
import 'package:moneyboys/Shared/widgets/custom_scaffold.dart';
import 'package:moneyboys/app/config/route-path.dart';

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
              backgroundColor: Colors.red,
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
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: AppScaffold(
        title: "MoneyBoys",

        showBackButton: false,

        // Thêm màu nền cho AppScaffold (nếu nó là CustomScaffold)
        // body của _SignUpViewState.build()
        body: Container(
          margin: const EdgeInsets.all(16),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            // Bỏ const để dùng BoxDecoration
            // Nền form: TRẮNG XÁM NHẠT (đồng bộ với nền field)
            color: Colors.grey[100],
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            // VIỀN XANH ĐẬM (đồng bộ với màn hình Đăng nhập)
            border: Border.all(
              color: const Color.fromARGB(255, 10, 127, 223),
              width: 1.5,
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formSignupKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    // Bỏ const vì đang dùng biến màu
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      // Tiêu đề màu XANH ĐẬM
                      color: Colors.blue[800],
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    // Chữ nhập vào màu ĐEN
                    style: const TextStyle(color: Colors.black),
                    validator: context.read<SignUpCubit>().validateName,
                    decoration: _inputDecoration('Full Name'),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    // Chữ nhập vào màu ĐEN
                    style: const TextStyle(color: Colors.black),
                    validator: context.read<SignUpCubit>().validateEmail,
                    decoration: _inputDecoration('Email'),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    // Chữ nhập vào màu ĐEN
                    style: const TextStyle(color: Colors.black),
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

                          color: Colors.blue.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Checkbox
                  Row(
                    children: [
                      Checkbox(
                        activeColor: Colors.blue.shade600,
                        value: _agreePersonalData,
                        onChanged: (val) {
                          setState(() => _agreePersonalData = val!);
                        },
                      ),
                      Expanded(
                        // Bỏ const
                        child: Text(
                          'I agree to the processing of personal data',

                          style: TextStyle(color: Colors.blue[700]),
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
                            // Nút màu XANH TRUNG BÌNH
                            backgroundColor: Colors.blue.shade600,
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
                                      Colors.black, // Indicator màu TRẮNG
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.black, // Chữ nút màu TRẮNG
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),

                  // Navigate to Sign In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        // Bỏ const
                        'Already have an account? ',
                        // Chữ màu XANH NHẠT
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            RoutePath.signIn,
                          );
                        },
                        child: Text(
                          // Bỏ const
                          'Sign in',
                          style: TextStyle(
                            // Link màu XANH ĐẬM
                            color: Colors.blue.shade800,
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
      labelStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color.fromARGB(255, 235, 154, 4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color.fromARGB(255, 8, 97, 198)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 235, 154, 4),
          width: 5,
        ),
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
