import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/student_service.dart';
import '../../services/local_session_service.dart';
import '../../services/whitelist_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';

class StudentEntryScreen extends StatefulWidget {
  const StudentEntryScreen({super.key});

  @override
  State<StudentEntryScreen> createState() => _StudentEntryScreenState();
}

class _StudentEntryScreenState extends State<StudentEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _batchController = TextEditingController();
  final _passwordController = TextEditingController();

  final StudentService _studentService = StudentService();
  final LocalSessionService _sessionService = LocalSessionService();
  final WhitelistService _whitelistService = WhitelistService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final student = await _sessionService.getCurrentStudent();
    if (student != null) {
      if (mounted) {
        context.read<AuthProvider>().setRole('student');
        Navigator.pushReplacementNamed(context, '/student-dashboard');
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final name = _nameController.text.trim();
      final batch = int.parse(_batchController.text.trim());
      final password = _passwordController.text.trim();

      try {
        // Step 1: Check Whitelist
        final whitelisted = await _whitelistService.checkWhitelist(name, batch, password);
        
        if (whitelisted == null) {
          throw Exception('You are not authorized to access the system. Please contact Admin.');
        }

        // Step 2: Proceed to create/find student record
        final student = await _studentService.findOrCreateStudent(
          name: name,
          batch: batch,
          studentId: password, // Using password as student ID for now or keep it distinct
        );

        await _sessionService.saveCurrentStudent(student);

        if (mounted) {
          context.read<AuthProvider>().setRole('student');
          Navigator.pushReplacementNamed(context, '/student-dashboard');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')), 
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative background elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.studentPrimary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.adminPrimary.withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large, vertical: AppSpacing.xlarge),
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
                                colors: [AppColors.studentPrimary, AppColors.adminPrimary],
                              ).createShader(bounds),
                              child: const Icon(Icons.meeting_room_rounded, size: 60, color: Colors.white),
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
                                    color: AppColors.studentPrimary,
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
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Student Portal',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.heading2.copyWith(color: AppColors.studentPrimary),
                              ),
                              const SizedBox(height: AppSpacing.small),
                              Text(
                                'Authorized students only',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
                              ),
                              const SizedBox(height: AppSpacing.xlarge),
                              
                              _buildTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                icon: Icons.person_outline_rounded,
                                validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              _buildTextField(
                                controller: _batchController,
                                label: 'Batch (Year)',
                                icon: Icons.calendar_today_rounded,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Batch is required';
                                  if (int.tryParse(v) == null) return 'Must be a number';
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Access Password',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                validator: (v) => v == null || v.isEmpty ? 'Password is required' : null,
                              ),
                              const SizedBox(height: AppSpacing.xlarge),
                              
                              // Gradient Submit Button
                              _buildSubmitButton(),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xlarge),
                      
                      // Footer Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Administrative access?',
                            style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/admin-login'),
                            child: Text(
                              'Admin Login',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.adminPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
        prefixIcon: Icon(icon, color: AppColors.studentPrimary, size: 22),
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
        fillColor: AppColors.background.withOpacity(0.5),
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
          borderSide: const BorderSide(color: AppColors.studentPrimary, width: 1.5),
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
        gradient: LinearGradient(
          colors: [AppColors.studentPrimary, AppColors.studentSecondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.studentPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _submit,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'CONTINUE',
                    style: AppTextStyles.bodyBold.copyWith(color: Colors.white, letterSpacing: 1.2),
                  ),
          ),
        ),
      ),
    );
  }
}
