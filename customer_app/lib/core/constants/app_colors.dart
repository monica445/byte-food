import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFFB5B21);
  static const Color primaryHover = Color(0xFFE94B14);
  static const Color primaryLight = Color(0xFFFFEADE);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Backgrounds
  static const Color background = Color(0xFFFFFAF7);
  static const Color backgroundTint = Color(0xFFFFF7F2);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Borders and disabled elements
  static const Color border = Color(0xFFF1E7E1);
  static const Color disabled = Color(0xFFD1D5DB);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);

  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);
}
