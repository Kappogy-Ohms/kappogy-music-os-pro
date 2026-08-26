import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum DynamicGrade {
  audiophileMaster('AUDIOPHILE DYNAMIC', 'DR14 - DR20: Exceptional acoustic dynamic range and transient headroom.', AppColors.kappogyGreen),
  balanced('BALANCED DYNAMIC', 'DR9 - DR13: Natural, modern dynamic master with good transient clarity.', AppColors.ledCyan),
  moderate('MODERATE COMPRESSION', 'DR6 - DR8: Radio / streaming normalized master with limited dynamic punch.', AppColors.kappogyYellow),
  brickwalled('BRICKWALLED / CLIPPED', 'DR1 - DR5: Heavy compression & limiting (Loudness War style), low headroom.', AppColors.kappogyRed);

  final String label;
  final String description;
  final Color color;
  const DynamicGrade(this.label, this.description, this.color);
}

class DynamicRangeReport {
  final int drScore; // 1 to 20
  final double peakDbfs; // e.g. -0.1 dBFS
  final double rmsDbfs; // e.g. -11.8 dBFS
  final double crestFactorDb; // peakDbfs - rmsDbfs
  final DynamicGrade grade;
  final bool hasTruePeakClipping; // peak >= -0.05 dBFS
  final String trackTitle;

  const DynamicRangeReport({
    required this.drScore,
    required this.peakDbfs,
    required this.rmsDbfs,
    required this.crestFactorDb,
    required this.grade,
    required this.hasTruePeakClipping,
    required this.trackTitle,
  });

  static DynamicRangeReport evaluate({
    required String trackTitle,
    double? customPeak,
    double? customRms,
    int? customDr,
  }) {
    final peak = customPeak ?? -0.2;
    final rms = customRms ?? -13.5;
    final crest = peak - rms;
    final dr = customDr ?? (crest.round().clamp(1, 20));

    DynamicGrade grade;
    if (dr >= 14) {
      grade = DynamicGrade.audiophileMaster;
    } else if (dr >= 9) {
      grade = DynamicGrade.balanced;
    } else if (dr >= 6) {
      grade = DynamicGrade.moderate;
    } else {
      grade = DynamicGrade.brickwalled;
    }

    return DynamicRangeReport(
      drScore: dr,
      peakDbfs: peak,
      rmsDbfs: rms,
      crestFactorDb: crest,
      grade: grade,
      hasTruePeakClipping: peak >= -0.05,
      trackTitle: trackTitle,
    );
  }

  static DynamicRangeReport analyzeSamples(List<double> samples, {String trackTitle = 'Audio Stream'}) {
    if (samples.isEmpty) {
      return evaluate(trackTitle: trackTitle);
    }

    double maxAmp = 0.0;
    double sumSquares = 0.0;

    for (final s in samples) {
      final absVal = s.abs();
      if (absVal > maxAmp) maxAmp = absVal;
      sumSquares += s * s;
    }

    final rmsVal = sqrt(sumSquares / samples.length);
    // Convert to dBFS
    final peakDb = maxAmp > 0 ? (20 * log(maxAmp) / ln10) : -96.0;
    final rmsDb = rmsVal > 0 ? (20 * log(rmsVal) / ln10) : -96.0;
    final crest = (peakDb - rmsDb).clamp(1.0, 20.0);

    return evaluate(
      trackTitle: trackTitle,
      customPeak: peakDb.clamp(-96.0, 3.0),
      customRms: rmsDb.clamp(-96.0, 0.0),
      customDr: crest.round().clamp(1, 20),
    );
  }
}
