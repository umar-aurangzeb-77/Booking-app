import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final IconData leadingIcon;
  final bool isPassword;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.placeholder,
    required this.leadingIcon,
    this.isPassword = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondaryText, 
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            style: AppTextStyles.body,
            keyboardType: widget.isPassword ? TextInputType.text : TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.secondaryText.withOpacity(0.5)),
              prefixIcon: Icon(widget.leadingIcon, color: AppColors.secondaryText),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.secondaryText),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
