import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Luxury Botanical
  static const Color primary = Color(0xFF2D4A3E); // Deep Forest Sage
  static const Color primaryLight = Color(0xFF436B5B);
  static const Color primaryDark = Color(0xFF1B3028);

  // Accent & Romantic Highlights
  static const Color accentRose = Color(0xFFE58C8A); // Dusty Blush Rose
  static const Color accentRoseLight = Color(0xFFFDECEB);
  static const Color accentGold = Color(0xFFC59B27); // Warm Champagne Gold
  static const Color accentGoldLight = Color(0xFFF9F3E3);

  // Background & Surfaces
  static const Color background = Color(0xFFFBF9F5); // Cream Vanilla Canvas
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F1EA);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E2822); // Deep Charcoal
  static const Color textSecondary = Color(0xFF6B7A72); // Muted Sage Gray
  static const Color textLight = Color(0xFF9EABA4);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status & Badges
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  // Borders & Dividers
  static const Color border = Color(0xFFE7E1D8);
  static const Color borderLight = Color(0xFFF0EBE3);
  static const Color shadow = Color(0x0D1E2822);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2D4A3E), Color(0xFF1B3028)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFF2A3A1), Color(0xFFE58C8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF2D4A3E), Color(0xFF3E6253), Color(0xFF21372E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFA67C1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
