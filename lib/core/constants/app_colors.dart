import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand (System Blue) ───────────────────────────────────
  static const Color primary = Color(0xFF0A84FF); // iOS System Blue
  static const Color primaryLight = Color(0xFF64D2FF);
  static const Color primaryDark = Color(0xFF0040DD);
  static const Color accent = Color(0xFF5E5CE6); // iOS System Indigo

  // ── Backgrounds (iOS Dark Style) ─────────────────────────
  static const Color background = Color(0xFF000000); // System Black
  static const Color surface = Color(0xFF1C1C1E); // System Gray 6 (Elevated)
  static const Color surfaceVariant = Color(0xFF2C2C2E); // System Gray 5
  static const Color cardBackground = Color(0xFF1C1C1E);

  // ── Text ────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93); // System Gray
  static const Color textHint = Color(0xFF636366); // System Gray 2
  static const Color textDisabled = Color(0xFF48484A); // System Gray 3

  // ── Status ──────────────────────────────────────────────
  static const Color success = Color(0xFF30D158); // iOS System Green
  static const Color error = Color(0xFFFF453A); // iOS System Red
  static const Color warning = Color(0xFFFF9F0A); // iOS System Orange
  static const Color info = Color(0xFF0A84FF);

  // ── UI Elements ─────────────────────────────────────────
  static const Color divider = Color(0xFF38383A); // System Gray 4
  static const Color border = Color(0xFF38383A);
  static const Color borderLight = Color(0xFF48484A);
  static const Color shimmerBase = Color(0xFF1C1C1E);
  static const Color shimmerHighlight = Color(0xFF2C2C2E);

  // ── Roles ───────────────────────────────────────────────
  static const Color studentBadge = Color(0xFF5E5CE6);
  static const Color alumniBadge = Color(0xFF0A84FF);
  static const Color adminBadge = Color(0xFFFF375F); // iOS System Pink

  // ── Gradients (Subtle) ───────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A84FF), Color(0xFF007AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF1C1C1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Glassmorphism ───────────────────────────────────────
  static const Color glassBase = Color(0x1Affffff); // White with 10% opacity
  static const Color glassBorder = Color(0x33ffffff); // White with 20% opacity
  static const Color glassHighlight = Color(0x4Dffffff); // White with 30% opacity
  static const Color glassDeepBackground = Color(0x66000000); // Black with 40% opacity
  
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF),
      Color(0x0FFFFFFF),
    ],
  );

  static const Color glassBackground = Color(0xBF1C1C1E); // For blur effects
  static const Color transparent = Colors.transparent;
  static const Color overlay = Color(0x99000000);
}

