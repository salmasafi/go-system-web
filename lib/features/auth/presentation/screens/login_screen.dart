import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/home/presentation/screens/home_screen.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button_widget.dart';
import '../../../../core/widgets/custom_text_faild_widget.dart';
import '../../../../core/widgets/simple_fadein_animation_widget.dart';
import '../../cubit/login_cubit.dart';
import '../../cubit/login_state.dart';
import '../widgets/custom_text_faild_widget.dart' hide CustomTextField;
import '../widgets/login_title_widget.dart';
import '../widgets/logo_and_title_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocProvider(
        create: (context) => LoginCubit(),
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login successful!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );

              // Navigate to home screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            } else if (state is LoginError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = LoginCubit.get(context);
            final isLoading = state is LoginLoading;

            return Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const LogoAndTitleWidget(),
                      const SizedBox(height: 50),
                      const LoginTitleWidget(),
                      const SizedBox(height: 24),
                      FadeInAnimation(
                        delay: const Duration(milliseconds: 600),
                        child: CustomTextField(
                          hasBorder: false,
                          hasBoxDecoration: true,
                          controller: _emailController,
                          labelText: "Email",
                          hintText: "admin@example.com",
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: LoginValidator.validateEmail,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeInAnimation(
                        delay: const Duration(milliseconds: 800),
                        child: CustomTextField(
                          hasBorder: false,
                          hasBoxDecoration: true,
                          controller: _passwordController,
                          labelText: "Password",
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onObscureChanged: (value) {
                            setState(() {
                              _obscurePassword = value;
                            });
                          },
                          prefixIcon: Icons.lock_outline,
                          validator: LoginValidator.validatePassword,
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeInAnimation(
                        delay: const Duration(milliseconds: 1000),
                        child: CustomElevatedButton(
                          onPressed: isLoading
                              ? () {} // Disable button during loading
                              : () {
                            if (_formKey.currentState!.validate()) {
                              cubit.userLogin(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );
                            }
                          },
                          text: "Login",
                          isLoading: isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}