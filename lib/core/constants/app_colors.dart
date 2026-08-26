import 'package:flutter/material.dart';

/// Centralized Color Palette for Kappogy Music OS Pro
/// Incorporates dark studio hardware finishes and the signature Kappogy Tri-Color Gradient.
class AppColors {
  // Studio Chassis & Hardware Surfaces
  static const Color chassisBg = Color(0xFF13151B);
  static const Color chassisSurface = Color(0xFF1C1E26);
  static const Color panelRaised = Color(0xFF242733);
  static const Color panelSunken = Color(0xFF0F1014);
  static const Color panelWell = Color(0xFF0B0C0F);

  // Lighting & Bevel Highlights (135deg Key Light)
  static const Color highlightSharp = Color(0x33FFFFFF);
  static const Color highlightSoft = Color(0x14FFFFFF);
  static const Color shadowDeep = Color(0xD9000000);
  static const Color shadowAmbient = Color(0x80000000);

  // Border Defs
  static const Color borderSubtle = Color(0x1AFFFFFF);
  static const Color borderProminent = Color(0x33FFFFFF);
  static const Color borderGlow = Color(0x4D00E5FF);

  // Kappogy Tri-Color Signature Identity
  static const Color kappogyRed = Color(0xFFE53935);
  static const Color kappogyYellow = Color(0xFFFBC02D);
  static const Color kappogyGreen = Color(0xFF43A047);

  // Luminous LED Accents & Indicators
  static const Color ledCyan = Color(0xFF00E5FF);
  static const Color ledBlue = Color(0xFF4D88FF);
  static const Color ledPurple = Color(0xFF9D65FF);
  static const Color ledAmber = Color(0xFFFFAA00);
  static const Color ledInactive = Color(0x2EFFFFFF);

  // Typography
  static const Color textPrimary = Color(0xFFF0F3FA);
  static const Color textSecondary = Color(0xFF98A2B8);
  static const Color textMuted = Color(0xFF5E6578);
  static const Color textDebossed = Color(0xFFD0D6E6);

  // Kappogy Tri-Color Linear Gradient
  static const LinearGradient kappogyGradient = LinearGradient(
    colors: [kappogyRed, kappogyYellow, kappogyGreen],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Studio Metallic Bevel Gradients
  static const LinearGradient raisedButtonGradient = LinearGradient(
    colors: [Color(0xFF2A2D39), Color(0xFF1E202A), Color(0xFF171821)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pressedButtonGradient = LinearGradient(
    colors: [Color(0xFF121319), Color(0xFF191B24), Color(0xFF20222D)],
    stops: [0.0, 0.6, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient knobDialGradient = RadialGradient(
    colors: [Color(0xFF2D303D), Color(0xFF1C1E26), Color(0xFF121318)],
    stops: [0.0, 0.65, 1.0],
    center: Alignment(-0.3, -0.3),
  );
}
