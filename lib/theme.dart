import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1F5EFF);
  static const primaryDark = Color(0xFF1747C9);
  static const primarySoft = Color(0xFFEAF0FF);
  static const bg = Color(0xFFF6F8FC);
  static const card = Colors.white;
  static const text = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);
  static const textLight = Color(0xFF94A3B8);
  static const border = Color(0xFFE6EBF3);
  static const input = Color(0xFFF2F5FA);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFE7F8EE);
  static const red = Color(0xFFEF4444);
  static const redSoft = Color(0xFFFDECEC);
  static const orange = Color(0xFFF59E0B);
  static const orangeSoft = Color(0xFFFEF3E2);
  static const purple = Color(0xFF8B5CF6);
  static const purpleSoft = Color(0xFFF1EBFE);
  static const pink = Color(0xFFEC4899);
  static const pinkSoft = Color(0xFFFDEBF4);
  static const whatsapp = Color(0xFF22C55E);
  static const chip = Color(0xFFEEF2FA);
  static const navy = Color(0xFF1E293B);
}

/// Initials-avatar palette, picked deterministically from the name.
/// Mixes pastel (tinted bg, coloured text) and solid (coloured bg, white text) styles as in the design.
const avatarPalette = <(Color, Color)>[
  (Color(0xFFFDE2E4), Color(0xFFE11D48)),
  (Color(0xFF3B82F6), Colors.white),
  (Color(0xFFD1FAE5), Color(0xFF059669)),
  (Color(0xFF8B5CF6), Colors.white),
  (Color(0xFF2563EB), Colors.white),
  (Color(0xFF22C55E), Colors.white),
  (Color(0xFFFCE7F3), Color(0xFFDB2777)),
];

const cardShadow = [BoxShadow(color: Color(0x0F0F172A), blurRadius: 12, offset: Offset(0, 2))];

const raisedShadow = [BoxShadow(color: Color(0x591F5EFF), blurRadius: 18, offset: Offset(0, 6))];

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary, surface: Colors.white),
    scaffoldBackgroundColor: AppColors.bg,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: AppColors.text, displayColor: AppColors.text),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.text,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.text,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}
