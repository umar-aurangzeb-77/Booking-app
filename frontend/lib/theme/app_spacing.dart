import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xlarge = 32.0;


  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHorizontalPadding(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.06;
  }

  static double screenVerticalPadding(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.02;
  }

  static double smallVerticalSpacing(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.01;
  }

  static double smallHorizontalSpacing(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.02;
  }

  static double mediumVerticalSpacing(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.02;
  }

  static double mediumHorizontalSpacing(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.03;
  }

  static double largeVerticalSpacing(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.04;
  }

  static double largeHorizontalSpacing(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.05;
  }

  static double extraLargeVerticalSpacing(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.05;
  }

  static EdgeInsets screenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: screenHorizontalPadding(context),
    );
  }

  static EdgeInsets bottomNavigationPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: screenHorizontalPadding(context),
      vertical: screenVerticalPadding(context),
    );
  }
}
