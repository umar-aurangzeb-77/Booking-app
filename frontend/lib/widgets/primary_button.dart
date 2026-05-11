import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56, // Good touch target height
      child: ElevatedButton(
        onPressed: isLoading ? () {} : onPressed,
        // Radii, Colors are automatically applied by the AppTheme elevatedButtonTheme setup
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white, 
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
