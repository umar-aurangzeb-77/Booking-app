import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/logo_header.dart';
import '../widgets/app_text_field.dart';
import '../widgets/forgot_password_text.dart';
import '../widgets/remember_me_checkbox.dart';
import '../widgets/primary_button.dart';
import '../widgets/bottom_text_link.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().login(email, password);
      if (mounted) {
        context.read<AuthProvider>().setRole('student');
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xlarge),
              const LogoHeader(),
              const SizedBox(height: AppSpacing.large),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Sign in to continue booking',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xlarge),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                placeholder: 'name@example.com',
                leadingIcon: Icons.email_outlined,
              ),
              const SizedBox(height: AppSpacing.medium),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                placeholder: '••••••••',
                leadingIcon: Icons.lock_outline_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RememberMeCheckbox(
                    value: _rememberMe,
                    onChanged: (val) => setState(() => _rememberMe = val ?? false),
                  ),
                  ForgotPasswordText(onPressed: () {}),
                ],
              ),
              const SizedBox(height: AppSpacing.large),
              PrimaryButton(
                text: 'Login',
                onPressed: _signIn,
                isLoading: authProvider.isLoading,
              ),
              const SizedBox(height: AppSpacing.large),
              BottomTextLink(
                text: "Don't have an account? ",
                linkText: 'Sign Up',
                onTapped: () => Navigator.pushNamed(context, '/signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
