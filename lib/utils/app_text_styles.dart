import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headline styles
  static const TextStyle headline1 = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body styles
  static const TextStyle body1 = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Label styles
  static const TextStyle label = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle labelPrimary = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 1.2,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
