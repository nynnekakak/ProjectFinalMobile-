import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyboys/Modules/SignIn/Cubit/signin_cubit.dart';
import 'package:moneyboys/Modules/SignIn/Cubit/signin_state.dart';
import 'package:moneyboys/Modules/forgot_screen.dart';
import 'package:moneyboys/Shared/widgets/custom_scaffold.dart';
import 'package:moneyboys/app/config/route-path.dart';
import 'package:moneyboys/app/route.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInCubit(),
      child: const SignInView(),
    );
  }
}

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formSignInKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _rememberPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (!_formSignInKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    context.read<SignInCubit>().signIn(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInCubit, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign in successful'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Routes()),
          );
        } else if (state is SignInFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: AppScaffold(
        title: "MoneyBoys",

        showBackButton: false,
        body: Container(
          margin: const EdgeInsets.all(16),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color:
                Colors.grey[100], // Thay đổi nền thành màu xám nhạt (trắng xám)
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            border: Border.all(
              color: const Color.fromARGB(
                255,
                10,
                127,
                223,
              ), // Màu viền xanh nhạt
              width: 1.5, // Độ dày của viền
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formSignInKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const SizedBox(height: 10),
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .blue[800], // Thay đổi màu chữ thành xanh đậm để hài hòa
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(
                      color: Colors.black,
                    ), // Thay đổi màu chữ thành xanh
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Colors.blue[600],
                      ), // Thay đổi màu label thành xanh nhạt
                      filled: true,
                      fillColor: Colors
                          .grey[200], // Thay đổi fillColor thành xám nhạt để hài hòa
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.blue[300]!,
                        ), // Thay đổi viền thành xanh nhạt
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.blue[300]!,
                        ), // Thay đổi viền enabled thành xanh nhạt
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors
                              .blue[600]!, // Thay đổi viền focused thành xanh đậm
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(
                      color: Colors.black,
                    ), // Thay đổi màu chữ thành xanh
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Colors.blue[600],
                      ), // Thay đổi màu label thành xanh nhạt
                      filled: true,
                      fillColor: Colors
                          .grey[200], // Thay đổi fillColor thành xám nhạt để hài hòa
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
                          color: Colors
                              .blue[600], // Thay đổi màu icon thành xanh nhạt
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.blue[300]!,
                        ), // Thay đổi viền enabled thành xanh nhạt
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors
                              .blue[600]!, // Thay đổi viền focused thành xanh đậm
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Remember me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Checkbox(
                            activeColor: Colors
                                .blue[600], // Thay đổi màu checkbox thành xanh
                            value: _rememberPassword,
                            onChanged: (val) {
                              setState(() => _rememberPassword = val!);
                            },
                          ),
                          Text(
                            'Remember me',
                            style: TextStyle(
                              color: Colors.blue[700],
                            ), // Thay đổi màu text thành xanh
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors
                                .blue[800], // Thay đổi màu text thành xanh đậm
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Sign In Button
                  BlocBuilder<SignInCubit, SignInState>(
                    builder: (context, state) {
                      final isLoading = state is SignInLoading;

                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .blue[600], // Thay đổi màu button thành xanh để hài hòa với theme
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
                                      Colors
                                          .white, // Giữ màu trắng cho indicator
                                    ),
                                  ),
                                )
                              : Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors
                                        .white, // Giữ màu trắng cho text button
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.blue[700],
                        ), // Thay đổi màu text thành xanh
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            RoutePath.signUp,
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors
                                .blue[800], // Thay đổi màu text thành xanh đậm
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
}
