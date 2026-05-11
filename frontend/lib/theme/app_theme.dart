import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData _buildTheme({
    required Color primaryColor,
    required Color secondaryColor,
    Color? scaffoldBackgroundColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackgroundColor ?? AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: AppTextStyles.heading1,
        headlineLarge: AppTextStyles.heading2,
        titleLarge: AppTextStyles.heading2,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.body,
      ),
      cardTheme: const CardTheme(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading2.copyWith(color: AppColors.primaryText),
        iconTheme: const IconThemeData(color: AppColors.primaryText),
      ),
    );
  }

  static ThemeData get lightTheme => _buildTheme(
        primaryColor: AppColors.primaryBlue,
        secondaryColor: AppColors.lightBlue,
      );

  static ThemeData get studentTheme => _buildTheme(
        primaryColor: AppColors.studentPrimary,
        secondaryColor: AppColors.studentSecondary,
      );

  static ThemeData get adminTheme => _buildTheme(
        primaryColor: AppColors.adminPrimary,
        secondaryColor: AppColors.adminPrimary,
        scaffoldBackgroundColor: AppColors.adminBackground,
      );
}
