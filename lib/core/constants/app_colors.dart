import 'package:flutter/material.dart';

class AppColors {
  // ── Brand Blue  (logo: shopping bag + "Go") ──────────────────────────────
  static const Color primaryBlue = Color(0xFF1A3FC4);
  static const Color darkBlue    = Color(0xFF102880);
  static const MaterialColor mediumBlue700 = MaterialColor(
    0xFF1A3FC4,
    <int, Color>{
      50:  Color(0xFFE8EEFA),
      100: Color(0xFFC5D3F4),
      200: Color(0xFF9FB7EE),
      300: Color(0xFF789AE8),
      400: Color(0xFF5A83E3),
      500: Color(0xFF3D6DDD),
      600: Color(0xFF2F5FCF),
      700: Color(0xFF1A3FC4),
      800: Color(0xFF102880),
      900: Color(0xFF061260),
    },
  );

  // ── Brand Green (logo: checkmark + "System") ─────────────────────────────
  static const Color successGreen = Color(0xFF1A7A1A);
  static const Color darkGreen    = Color(0xFF115511);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color lightBlueBackground = Color(0xFFEEF2FF);
  static const Color white               = Color(0xFFFFFFFF);

  // ── Borders & Dividers ────────────────────────────────────────────────────
  static const Color lightGray = Color(0xFFE0E0E0);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color darkGray  = Color(0xFF333333);
  static const Color linkBlue  = Color(0xFF757575);
  static const shadowGray      = Colors.grey;

  // ── Grey Scale (replaces direct Colors.grey[X] calls) ────────────────────
  static const Color greyLight  = Color(0xFFF5F5F5);  // ≈ grey[100]
  static const Color greyMedium = Color(0xFFBDBDBD);  // ≈ grey[400]
  static const Color greyDark   = Color(0xFF616161);  // ≈ grey[700]

  // ── Semantic / Status ─────────────────────────────────────────────────────
  static const Color red            = Color(0xFFF44336);
  static const Color warningOrange  = Color(0xFFFF9800);
  static const Color categoryPurple = Color(0xFF9C27B0);
  static const Color clearPink      = Color(0xFFFF6B9D);
  static const Color holdBeige      = Color(0xFFFFD54F);
  static const black                = Colors.black;

  // ── Aliases (backward compat) ─────────────────────────────────────────────
  static const primaryRed      = primaryBlue;
  static const darkRed         = darkBlue;
  static const lightBackground = lightBlueBackground;
  static const mediumGray      = linkBlue;
}
