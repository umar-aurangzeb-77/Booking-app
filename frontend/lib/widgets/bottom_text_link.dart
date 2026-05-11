import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BottomTextLink extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onTapped;

  const BottomTextLink({
    super.key, 
    required this.text, 
    required this.linkText, 
    required this.onTapped
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: text,
          style: AppTextStyles.body.copyWith(color: AppColors.secondaryText),
          children: [
            TextSpan(
              text: linkText,
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTapped,
            ),
          ],
        ),
      ),
    );
  }
}
