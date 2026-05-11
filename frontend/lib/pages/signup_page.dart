import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/logo_header.dart';
import '../widgets/bottom_text_link.dart';
import '../providers/auth_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().signUp(email, password, name);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Failed: ${e.toString()}')),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.large),
                const LogoHeader(),
                const SizedBox(height: AppSpacing.large),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  'Sign up to start booking rooms',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xlarge),
                AppTextField(
                  label: 'Full Name',
                  placeholder: 'Enter your full name',
                  controller: _nameController,
                  leadingIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.medium),
                AppTextField(
                  label: 'Email',
                  placeholder: 'Enter your email',
                  controller: _emailController,
                  leadingIcon: Icons.email_outlined,
                ),
                const SizedBox(height: AppSpacing.medium),
                AppTextField(
                  label: 'Password',
                  placeholder: 'Create a password',
                  controller: _passwordController,
                  isPassword: true,
                  leadingIcon: Icons.lock_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.xlarge),
                PrimaryButton(
                  text: 'Sign Up',
                  onPressed: _handleSignUp,
                  isLoading: authProvider.isLoading,
                ),
                const SizedBox(height: AppSpacing.large),
                BottomTextLink(
                  text: 'Already have an account? ',
                  linkText: 'Login',
                  onTapped: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
