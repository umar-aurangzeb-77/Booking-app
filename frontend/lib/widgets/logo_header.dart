import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icons/logo.png',
          height: 64,
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back',
          style: AppTextStyles.heading1,
        ),
        const SizedBox(height: 8),
        Text(
          'Please enter your credentials to access your account',
          style: AppTextStyles.body.copyWith(color: AppColors.secondaryText),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
