import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button_widget.dart';
import '../../../../core/widgets/simple_fadein_animation_widget.dart';
import '../widgets/custom_text_faild_widget.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
      });
      // Navigate or show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Form(
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
                    onPressed: _handleLogin,
                    text: "Login",
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}