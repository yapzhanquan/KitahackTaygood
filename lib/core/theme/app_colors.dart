import 'package:flutter/material.dart';

/// ProjekWatch Design System - Slate/Blue-Grey Color Palette
/// Inspired by Tailwind CSS color system for a premium Airbnb-like aesthetic
class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────────────────────────────────
  // SLATE PALETTE (Primary neutral tones - organic, OLED-friendly)
  // ─────────────────────────────────────────────────────────────────────────
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A); // Primary dark (not #000)

  // ─────────────────────────────────────────────────────────────────────────
  // SEMANTIC COLORS
  // ─────────────────────────────────────────────────────────────────────────
  static const Color background = slate50;
  static const Color surface = Colors.white;
  static const Color surfaceVariant = slate100;
  static const Color border = slate200;
  static const Color borderLight = Color(0xFFF1F5F9);

  // Text hierarchy
  static const Color textPrimary = slate900;
  static const Color textSecondary = slate500;
  static const Color textTertiary = slate400;
  static const Color textInverse = Colors.white;

  // ─────────────────────────────────────────────────────────────────────────
  // STATUS COLORS - Tint + Text style (subtle backgrounds with bold text)
  // ─────────────────────────────────────────────────────────────────────────
  
  // Green (Active)
  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);

  // Yellow/Amber (Slowing)
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);

  // Red (Stalled)
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);

  // Gray (Unverified)
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);

  // ─────────────────────────────────────────────────────────────────────────
  // CATEGORY COLORS
  // ─────────────────────────────────────────────────────────────────────────
  
  // Indigo (Housing)
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color indigo900 = Color(0xFF312E81);

  // Amber (Road) - reuse amber colors above
  
  // Cyan (Drainage)
  static const Color cyan50 = Color(0xFFECFEFF);
  static const Color cyan100 = Color(0xFFCFFAFE);
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color cyan600 = Color(0xFF0891B2);
  static const Color cyan700 = Color(0xFF0E7490);

  // Pink (School)
  static const Color pink50 = Color(0xFFFDF2F8);
  static const Color pink100 = Color(0xFFFCE7F3);
  static const Color pink500 = Color(0xFFEC4899);
  static const Color pink600 = Color(0xFFDB2777);
  static const Color pink700 = Color(0xFFBE185D);

  // ─────────────────────────────────────────────────────────────────────────
  // CONFIDENCE COLORS
  // ─────────────────────────────────────────────────────────────────────────
  
  // Blue (High confidence)
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);

  // ─────────────────────────────────────────────────────────────────────────
  // SPECIAL UI COLORS
  // ─────────────────────────────────────────────────────────────────────────
  static const Color cardBorder = slate200;
  static const Color divider = slate100;
  static const Color shadowColor = Color(0x0D000000); // 5% black
  static const Color overlayDark = Color(0x40000000); // 25% black
  static const Color overlayLight = Color(0xE6FFFFFF); // 90% white
  
  // Glassmorphism
  static const Color glassBg = Color(0xCCFFFFFF); // 80% white
  static const Color glassStroke = Color(0x33FFFFFF); // 20% white
}
