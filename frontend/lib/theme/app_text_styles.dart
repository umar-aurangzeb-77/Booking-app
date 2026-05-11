import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading1 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      );

  static TextStyle get heading2 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      );

  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500, // Medium
        color: AppColors.primaryText,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal, // Regular
        color: AppColors.primaryText,
      );

  static TextStyle get bodyBold => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      );
}
