import 'package:flutter/material.dart';

/// ProjekWatch Design System - 8pt Grid Spacing System
/// All spacing values are multiples of 8 for visual consistency
class AppSpacing {
  AppSpacing._();

  // ─────────────────────────────────────────────────────────────────────────
  // BASE UNIT
  // ─────────────────────────────────────────────────────────────────────────
  static const double unit = 8.0;

  // ─────────────────────────────────────────────────────────────────────────
  // SPACING SCALE (8pt grid)
  // ─────────────────────────────────────────────────────────────────────────
  static const double xxs = 4.0;   // 0.5x - tight spacing
  static const double xs = 8.0;    // 1x
  static const double sm = 12.0;   // 1.5x
  static const double md = 16.0;   // 2x
  static const double lg = 20.0;   // 2.5x - card inner padding
  static const double xl = 24.0;   // 3x
  static const double xxl = 32.0;  // 4x - section margins
  static const double xxxl = 40.0; // 5x
  static const double huge = 48.0; // 6x
  static const double massive = 64.0; // 8x

  // ─────────────────────────────────────────────────────────────────────────
  // SEMANTIC SPACING
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Page horizontal padding (Airbnb uses ~24px)
  static const double pagePadding = xl;
  
  /// Section vertical margin (generous for "breathing room")
  static const double sectionMargin = xxl;
  
  /// Card inner padding (generous for premium feel)
  static const double cardPadding = lg;
  
  /// List item spacing
  static const double listItemGap = md;
  
  /// Inline element spacing (e.g., badge to badge)
  static const double inlineGap = xs;
  
  /// Icon to text spacing
  static const double iconTextGap = xs;
  
  /// Section header bottom margin
  static const double headerMargin = md;

  // ─────────────────────────────────────────────────────────────────────────
  // BORDER RADIUS (consistent rounding)
  // ─────────────────────────────────────────────────────────────────────────
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;  // Card radius (Airbnb-style)
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0; // Pill shape

  // ─────────────────────────────────────────────────────────────────────────
  // EDGE INSETS HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: pagePadding);
  static const EdgeInsets pagePaddingAll = EdgeInsets.all(pagePadding);
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);
  
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: pagePadding,
    vertical: sectionMargin,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SIZES
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Bottom bar height
  static const double bottomBarHeight = 80.0;
  
  /// App bar height
  static const double appBarHeight = 56.0;
  
  /// Card image aspect ratio (16:9)
  static const double cardImageAspectRatio = 16 / 9;
  
  /// Card minimum width
  static const double cardMinWidth = 280.0;
  
  /// Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  
  /// Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 52.0;
}
