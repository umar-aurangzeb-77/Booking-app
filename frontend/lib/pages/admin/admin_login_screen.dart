import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@gmail.com');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;

  void _login() {
    if (_formKey.currentState!.validate()) {
      if (_emailController.text == 'admin@gmail.com' && _passwordController.text == 'admin123') {
        context.read<AuthProvider>().setRole('admin');
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid admin credentials'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Decorative background elements (Red themed)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.adminPrimary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.adminPrimary.withOpacity(0.03),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large, vertical: AppSpacing.medium),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    children: [
                      // Logo and App Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/logo.png',
                            height: 60,
                            errorBuilder: (context, error, stackTrace) => ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [AppColors.adminPrimary, AppColors.adminPrimary.withOpacity(0.7)],
                              ).createShader(bounds),
                              child: const Icon(Icons.admin_panel_settings_rounded, size: 60, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.medium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Room Booking',
                                  style: AppTextStyles.heading1.copyWith(
                                    fontSize: 24,
                                    height: 1.1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Application',
                                  style: AppTextStyles.heading1.copyWith(
                                    fontSize: 24,
                                    color: AppColors.adminPrimary,
                                    height: 1.1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSpacing.xlarge),
                      
                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xlarge),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.large),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.adminPrimary.withOpacity(0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.adminPrimary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_person_rounded,
                                  color: AppColors.adminPrimary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              Text(
                                'Admin Control',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.heading2.copyWith(color: AppColors.adminPrimary),
                              ),
                              const SizedBox(height: AppSpacing.small),
                              Text(
                                'Secure login for administrators only',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
                              ),
                              const SizedBox(height: AppSpacing.xlarge),
                              
                              _buildTextField(
                                controller: _emailController,
                                label: 'Admin Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v == null || v.isEmpty ? 'Email is required' : null,
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                validator: (v) => v == null || v.isEmpty ? 'Password is required' : null,
                              ),
                              const SizedBox(height: AppSpacing.xlarge),
                              
                              // Red Gradient Submit Button
                              _buildSubmitButton(),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xlarge),
                      
                      // Footer Link
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Back to Student Portal',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && _obscurePassword,
      validator: validator,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
        prefixIcon: Icon(icon, color: AppColors.adminPrimary, size: 22),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppColors.secondaryText,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
          : null,
        filled: true,
        fillColor: AppColors.adminPrimary.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.adminPrimary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium, vertical: AppSpacing.medium),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        gradient: const LinearGradient(
          colors: [AppColors.adminPrimary, Color(0xFFD66062)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.adminPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _login,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: const Center(
            child: Text(
              'ADMIN LOGIN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
