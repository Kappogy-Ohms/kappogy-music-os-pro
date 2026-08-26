import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';

class PeqBand {
  final String name;
  final double frequencyHz; // 20 to 20000 Hz
  final double gainDb; // -18.0 to +18.0 dB
  final double qFactor; // 0.3 to 10.0
  final bool isEnabled;

  const PeqBand({
    required this.name,
    required this.frequencyHz,
    this.gainDb = 0.0,
    this.qFactor = 1.0,
    this.isEnabled = true,
  });

  PeqBand copyWith({
    String? name,
    double? frequencyHz,
    double? gainDb,
    double? qFactor,
    bool? isEnabled,
  }) {
    return PeqBand(
      name: name ?? this.name,
      frequencyHz: frequencyHz ?? this.frequencyHz,
      gainDb: gainDb ?? this.gainDb,
      qFactor: qFactor ?? this.qFactor,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class ParametricPeqState {
  final bool isMasterEnabled;
  final int activeBandIndex;
  final List<PeqBand> bands;

  const ParametricPeqState({
    this.isMasterEnabled = true,
    this.activeBandIndex = 2,
    this.bands = const [
      PeqBand(name: 'LOW SHELF', frequencyHz: 80.0, gainDb: 2.0, qFactor: 0.7),
      PeqBand(name: 'LOW MID', frequencyHz: 350.0, gainDb: -1.5, qFactor: 1.4),
      PeqBand(name: 'MID', frequencyHz: 1200.0, gainDb: 3.0, qFactor: 2.0),
      PeqBand(name: 'HIGH MID', frequencyHz: 4500.0, gainDb: 1.0, qFactor: 1.8),
      PeqBand(name: 'HIGH SHELF', frequencyHz: 12000.0, gainDb: 2.5, qFactor: 0.7),
    ],
  });

  ParametricPeqState copyWith({
    bool? isMasterEnabled,
    int? activeBandIndex,
    List<PeqBand>? bands,
  }) {
    return ParametricPeqState(
      isMasterEnabled: isMasterEnabled ?? this.isMasterEnabled,
      activeBandIndex: activeBandIndex ?? this.activeBandIndex,
      bands: bands ?? this.bands,
    );
  }
}

class ParametricPeqNotifier extends StateNotifier<ParametricPeqState> {
  ParametricPeqNotifier() : super(const ParametricPeqState());

  void toggleMaster() => state = state.copyWith(isMasterEnabled: !state.isMasterEnabled);
  void selectBand(int index) => state = state.copyWith(activeBandIndex: index.clamp(0, state.bands.length - 1));

  void updateBand(int idx, {double? frequency, double? gain, double? q}) {
    if (idx < 0 || idx >= state.bands.length) return;
    final current = state.bands[idx];
    final updated = current.copyWith(
      frequencyHz: frequency ?? current.frequencyHz,
      gainDb: gain ?? current.gainDb,
      qFactor: q ?? current.qFactor,
    );
    final newBands = List<PeqBand>.from(state.bands);
    newBands[idx] = updated;
    state = state.copyWith(bands: newBands);
  }

  void updateActiveBand({double? freq, double? gain, double? q}) {
    updateBand(state.activeBandIndex, frequency: freq, gain: gain, q: q);
  }

  void resetFlat() {
    state = state.copyWith(
      bands: [
        state.bands[0].copyWith(gainDb: 0.0),
        state.bands[1].copyWith(gainDb: 0.0),
        state.bands[2].copyWith(gainDb: 0.0),
        state.bands[3].copyWith(gainDb: 0.0),
        state.bands[4].copyWith(gainDb: 0.0),
      ],
    );
  }
}

final parametricPeqProvider = StateNotifierProvider<ParametricPeqNotifier, ParametricPeqState>((ref) {
  return ParametricPeqNotifier();
});

class ParametricPeqSheet extends ConsumerWidget {
  const ParametricPeqSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ParametricPeqSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peqState = ref.watch(parametricPeqProvider);
    final notifier = ref.read(parametricPeqProvider.notifier);
    final activeBand = peqState.bands[peqState.activeBandIndex];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.chassisBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: 30, spreadRadius: 5, offset: Offset(0, -10)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.show_chart_rounded, color: AppColors.kappogyGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '5-BAND CONTINUOUS PARAMETRIC EQUALIZER (PEQ)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Row(
                children: [
                  Tooltip(
                    message: 'Reset all PEQ bands to 0dB Flat',
                    child: SkeuoButton(
                      size: 32,
                      icon: Icons.refresh_rounded,
                      onPressed: notifier.resetFlat,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Toggle Parametric EQ Bypass',
                    child: SkeuoButton(
                      size: 32,
                      activeColor: AppColors.kappogyGreen,
                      isActive: peqState.isMasterEnabled,
                      onPressed: notifier.toggleMaster,
                      child: Icon(
                        Icons.power_settings_new_rounded,
                        size: 16,
                        color: peqState.isMasterEnabled ? AppColors.kappogyGreen : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Real-Time Parametric Bell Curve Display
          SkeuoPanel(
            showCornerScrews: true,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CONTINUOUS FREQUENCY SPLINE (20Hz - 20kHz)', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                    Text(
                      peqState.isMasterEnabled
                          ? '${activeBand.name} • ${activeBand.frequencyHz.toInt()}Hz (${activeBand.gainDb >= 0 ? '+' : ''}${activeBand.gainDb.toStringAsFixed(1)}dB)'
                          : 'BYPASS',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: peqState.isMasterEnabled ? AppColors.kappogyGreen : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomPaint(
                  size: const Size(double.infinity, 90),
                  painter: _PeqCurvePainter(
                    bands: peqState.bands,
                    activeIndex: peqState.activeBandIndex,
                    isEnabled: peqState.isMasterEnabled,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Band Selector Rocker
          const Text('SELECT PARAMETRIC BAND', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SkeuoRockerSwitch<int>(
              options: const [
                RockerOption(value: 0, label: '1 • Low Shelf'),
                RockerOption(value: 1, label: '2 • Low-Mid'),
                RockerOption(value: 2, label: '3 • Mid Bell'),
                RockerOption(value: 3, label: '4 • High-Mid'),
                RockerOption(value: 4, label: '5 • High Shelf'),
              ],
              selectedValue: peqState.activeBandIndex,
              activeColor: AppColors.kappogyGreen,
              onSelected: notifier.selectBand,
            ),
          ),

          const SizedBox(height: 18),

          // Knobs: FREQUENCY, GAIN, Q-FACTOR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Tooltip(
                message: 'Center frequency of selected band',
                child: SkeuoKnob(
                  label: 'FREQ',
                  value: activeBand.frequencyHz,
                  min: 20.0,
                  max: 20000.0,
                  size: 64,
                  ledColor: AppColors.ledCyan,
                  onChanged: peqState.isMasterEnabled ? (v) => notifier.updateActiveBand(freq: v) : (_) {},
                  displayValue: activeBand.frequencyHz >= 1000
                      ? '${(activeBand.frequencyHz / 1000).toStringAsFixed(1)}k'
                      : '${activeBand.frequencyHz.toInt()}Hz',
                ),
              ),
              Tooltip(
                message: 'Boost or cut gain in decibels (-18dB to +18dB)',
                child: SkeuoKnob(
                  label: 'GAIN',
                  value: activeBand.gainDb,
                  min: -18.0,
                  max: 18.0,
                  size: 64,
                  ledColor: AppColors.kappogyYellow,
                  onChanged: peqState.isMasterEnabled ? (v) => notifier.updateActiveBand(gain: v) : (_) {},
                  displayValue: '${activeBand.gainDb >= 0 ? '+' : ''}${activeBand.gainDb.toStringAsFixed(1)}dB',
                ),
              ),
              Tooltip(
                message: 'Filter bandwidth sharpness (Q-Factor 0.3 to 10.0)',
                child: SkeuoKnob(
                  label: 'Q-FACTOR',
                  value: activeBand.qFactor,
                  min: 0.3,
                  max: 10.0,
                  size: 64,
                  ledColor: AppColors.kappogyGreen,
                  onChanged: peqState.isMasterEnabled ? (v) => notifier.updateActiveBand(q: v) : (_) {},
                  displayValue: 'Q: ${activeBand.qFactor.toStringAsFixed(1)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeqCurvePainter extends CustomPainter {
  final List<PeqBand> bands;
  final int activeIndex;
  final bool isEnabled;

  _PeqCurvePainter({required this.bands, required this.activeIndex, required this.isEnabled});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final zeroY = height / 2;

    // Grid lines (0dB, +12dB, -12dB)
    final gridPaint = Paint()
      ..color = AppColors.borderSubtle.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, zeroY), Offset(width, zeroY), gridPaint);
    canvas.drawLine(Offset(0, height * 0.2), Offset(width, height * 0.2), gridPaint);
    canvas.drawLine(Offset(0, height * 0.8), Offset(width, height * 0.8), gridPaint);

    if (!isEnabled) {
      final bypassPaint = Paint()
        ..color = AppColors.textMuted.withValues(alpha: 0.5)
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(0, zeroY), Offset(width, zeroY), bypassPaint);
      return;
    }

    // Compute composite PEQ response
    final curvePath = Path();
    curvePath.moveTo(0, zeroY);

    for (double x = 0; x <= width; x += 3) {
      final normLog = x / width;
      final currentFreq = 20.0 * math.pow(1000.0, normLog); // 20Hz to 20kHz log scale
      double totalGain = 0.0;

      for (final band in bands) {
        final f0 = band.frequencyHz;
        final gain = band.gainDb;
        final q = band.qFactor;

        final delta = (math.log(currentFreq / f0) / math.ln10).abs();
        final bell = math.exp(-0.5 * math.pow(delta * q * 4.0, 2));
        totalGain += gain * bell;
      }

      final y = zeroY - (totalGain / 18.0) * (height * 0.4);
      curvePath.lineTo(x, y.clamp(5.0, height - 5.0));
    }

    // Draw curve fill gradient
    final fillPath = Path.from(curvePath)
      ..lineTo(width, zeroY)
      ..lineTo(0, zeroY)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.kappogyGreen.withValues(alpha: 0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw curve line
    final linePaint = Paint()
      ..color = AppColors.kappogyGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawPath(curvePath, linePaint);

    // Draw band center dots
    for (int i = 0; i < bands.length; i++) {
      final band = bands[i];
      final normLog = (math.log(band.frequencyHz / 20.0) / math.log(1000.0)).clamp(0.0, 1.0);
      final dotX = normLog * width;
      final dotY = zeroY - (band.gainDb / 18.0) * (height * 0.4);

      final dotPaint = Paint()
        ..color = i == activeIndex ? AppColors.kappogyYellow : AppColors.ledCyan
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), i == activeIndex ? 6.0 : 4.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PeqCurvePainter oldDelegate) {
    return oldDelegate.bands != bands || oldDelegate.activeIndex != activeIndex || oldDelegate.isEnabled != isEnabled;
  }
}
