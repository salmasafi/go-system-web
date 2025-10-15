import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/utils/validators.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_text_field_widget.dart';
import 'package:systego/core/widgets/simple_fadein_animation_widget.dart';
import 'package:systego/features/home/presentation/screens/home_screen.dart';
import '../../cubit/login_cubit.dart';
import '../../cubit/login_state.dart';
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
                SnackBar(
                  content: Text(
                    'Login successful!',
                    style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                  ),
                  margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
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
                  content: Text(
                    state.error,
                    style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                  ),
                  margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: ResponsiveUI.contentMaxWidth(context)),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.horizontalPadding(context),
                      vertical: ResponsiveUI.padding(context, 60),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const LogoAndTitleWidget(),
                        SizedBox(height: ResponsiveUI.spacing(context, 50)),
                        const LoginTitleWidget(),
                        SizedBox(height: ResponsiveUI.spacing(context, 24)),
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
                        SizedBox(height: ResponsiveUI.spacing(context, 20)),
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
                        SizedBox(height: ResponsiveUI.spacing(context, 30)),
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
              ),
            );
          },
        ),
      ),
    );
  }
}