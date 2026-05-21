import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // Border Radii
  static const double radiusValue = 14.0;
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(10.0));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(14.0));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(18.0));
  static const BorderRadius radius2xl = BorderRadius.all(Radius.circular(22.0));

  // Typography Styles
  static const TextStyle calligraphyStyle = TextStyle(
    fontFamily: 'ThuPhapViet',
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle headingXl = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: AppColors.ink,
    letterSpacing: -0.5,
  );

  static const TextStyle headingLg = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.ink,
  );

  static const TextStyle headingMd = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.ink,
  );

  static const TextStyle bodyLg = TextStyle(
    fontSize: 15.0,
    color: AppColors.ink,
    height: 1.5,
  );

  static const TextStyle bodyMd = TextStyle(
    fontSize: 14.0,
    color: AppColors.ink,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    color: AppColors.secondaryText,
  );

  static const TextStyle codeStyle = TextStyle(
    fontFamily: 'Courier',
    fontWeight: FontWeight.bold,
  );

  // Custom shadow for premium premium glass/paper effect
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      offset: const Offset(0, 4),
      blurRadius: 10.0,
      spreadRadius: 0.0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      offset: const Offset(0, 1),
      blurRadius: 3.0,
      spreadRadius: 0.0,
    ),
  ];
}
