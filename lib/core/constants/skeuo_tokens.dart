import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Skeuomorphic UI/UX Design System Tokens & Shadows
/// Mathematically modeled from 135deg top-left virtual key lighting.
class SkeuoTokens {
  // Raised Surface Drop & Bevel Shadows
  static const List<BoxShadow> raisedSm = [
    BoxShadow(
      color: AppColors.shadowAmbient,
      offset: Offset(0, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowDeep,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> raisedMd = [
    BoxShadow(
      color: AppColors.shadowAmbient,
      offset: Offset(0, 6),
      blurRadius: 14,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowDeep,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> raisedLg = [
    BoxShadow(
      color: AppColors.shadowDeep,
      offset: Offset(0, 10),
      blurRadius: 22,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.shadowAmbient,
      offset: Offset(0, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  // Sunken Milled Well Shadows (Recessed Channel & Pockets)
  static const List<BoxShadow> sunkenWell = [
    BoxShadow(
      color: AppColors.shadowDeep,
      offset: Offset(0, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x14FFFFFF),
      offset: Offset(0, -1),
      blurRadius: 1,
      spreadRadius: 0,
    ),
  ];

  // Pressed Depth (When a physical button is actively depressed)
  static const List<BoxShadow> pressedDepth = [
    BoxShadow(
      color: AppColors.shadowDeep,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // LED Glow Effects
  static List<BoxShadow> ledGlow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.6),
      offset: const Offset(0, 0),
      blurRadius: 8,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      offset: const Offset(0, 0),
      blurRadius: 16,
      spreadRadius: 3,
    ),
  ];

  // Debossed & Embossed Text Shadow
  static const List<Shadow> debossedText = [
    Shadow(
      color: Color(0x1AFFFFFF),
      offset: Offset(0, 1),
      blurRadius: 0,
    ),
    Shadow(
      color: Color(0xCC000000),
      offset: Offset(0, -1),
      blurRadius: 1,
    ),
  ];

  static const List<Shadow> embossedText = [
    Shadow(
      color: Color(0xCC000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
    Shadow(
      color: Color(0x33FFFFFF),
      offset: Offset(0, -1),
      blurRadius: 0,
    ),
  ];
}
