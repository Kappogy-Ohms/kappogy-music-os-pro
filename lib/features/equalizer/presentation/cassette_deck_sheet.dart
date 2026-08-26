import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';

enum CassetteTapeType {
  typeIFerric('Type I Normal Ferric', 'Warm analog compression with natural low-end warmth'),
  typeIIChrome('Type II High-Bias Chrome', 'Extended treble response with punchy dynamic snap'),
  typeIVMetal('Type IV Metal Alloy', 'Maximum magnetic headroom and pristine hi-fi clarity'),
  microCassette('Lo-Fi Micro-Cassette', 'Nostalgic 80s tape degradation and lo-fi wobble');

  final String label;
  final String description;
  const CassetteTapeType(this.label, this.description);
}

class CassetteDeckSettings {
  final bool isEnabled;
  final CassetteTapeType tapeType;
  final double wowFlutterPercent; // 0.0 to 100.0%
  final double tapeWearPercent; // 0.0 to 100.0%
  final double motorBiasGainDb; // 0.0 to 12.0 dB
  final bool isMechanicalNoiseEnabled;

  const CassetteDeckSettings({
    this.isEnabled = true,
    this.tapeType = CassetteTapeType.typeIFerric,
    this.wowFlutterPercent = 30.0,
    this.tapeWearPercent = 25.0,
    this.motorBiasGainDb = 4.0,
    this.isMechanicalNoiseEnabled = false,
  });

  CassetteDeckSettings copyWith({
    bool? isEnabled,
    CassetteTapeType? tapeType,
    double? wowFlutterPercent,
    double? tapeWearPercent,
    double? motorBiasGainDb,
    bool? isMechanicalNoiseEnabled,
  }) {
    return CassetteDeckSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      tapeType: tapeType ?? this.tapeType,
      wowFlutterPercent: wowFlutterPercent ?? this.wowFlutterPercent,
      tapeWearPercent: tapeWearPercent ?? this.tapeWearPercent,
      motorBiasGainDb: motorBiasGainDb ?? this.motorBiasGainDb,
      isMechanicalNoiseEnabled: isMechanicalNoiseEnabled ?? this.isMechanicalNoiseEnabled,
    );
  }
}

class CassetteDeckNotifier extends StateNotifier<CassetteDeckSettings> {
  CassetteDeckNotifier() : super(const CassetteDeckSettings());

  void toggleEnabled() => state = state.copyWith(isEnabled: !state.isEnabled);
  void setTapeType(CassetteTapeType t) => state = state.copyWith(tapeType: t);
  void setWowFlutter(double val) => state = state.copyWith(wowFlutterPercent: val.clamp(0.0, 100.0));
  void setTapeWear(double val) => state = state.copyWith(tapeWearPercent: val.clamp(0.0, 100.0));
  void setBias(double db) => state = state.copyWith(motorBiasGainDb: db.clamp(0.0, 12.0));
  void toggleMechanicalNoise() => state = state.copyWith(isMechanicalNoiseEnabled: !state.isMechanicalNoiseEnabled);
}

final cassetteDeckProvider = StateNotifierProvider<CassetteDeckNotifier, CassetteDeckSettings>((ref) {
  return CassetteDeckNotifier();
});

class CassetteDeckSheet extends ConsumerStatefulWidget {
  const CassetteDeckSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const CassetteDeckSheet(),
    );
  }

  @override
  ConsumerState<CassetteDeckSheet> createState() => _CassetteDeckSheetState();
}

class _CassetteDeckSheetState extends ConsumerState<CassetteDeckSheet> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(cassetteDeckProvider);
    final notifier = ref.read(cassetteDeckProvider.notifier);

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
                  Icon(Icons.album_rounded, color: AppColors.kappogyYellow, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'VINTAGE CASSETTE DECK & LO-FI MODULATOR',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Tooltip(
                message: 'Toggle Cassette Deck Motor Emulation',
                child: SkeuoButton(
                  size: 32,
                  activeColor: AppColors.kappogyYellow,
                  isActive: settings.isEnabled,
                  onPressed: notifier.toggleEnabled,
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    size: 16,
                    color: settings.isEnabled ? AppColors.kappogyYellow : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Skeuomorphic Dual-Spool Animated Cassette Tape Card
          SkeuoPanel(
            showCornerScrews: true,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      settings.tapeType.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: settings.isEnabled ? AppColors.kappogyYellow : AppColors.textMuted,
                      ),
                    ),
                    Text(
                      settings.isEnabled ? 'MOTOR RUNNING • 4.76 CM/S' : 'MOTOR STOPPED',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: settings.isEnabled ? AppColors.kappogyGreen : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return CustomPaint(
                      size: const Size(double.infinity, 70),
                      painter: _CassetteSpoolsPainter(
                        isEnabled: settings.isEnabled,
                        angle: _animController.value * 2 * math.pi,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Tape Type Rocker
          const Text('MAGNETIC TAPE FORMULATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SkeuoRockerSwitch<CassetteTapeType>(
              options: const [
                RockerOption(value: CassetteTapeType.typeIFerric, label: 'Type I Ferric'),
                RockerOption(value: CassetteTapeType.typeIIChrome, label: 'Type II Chrome'),
                RockerOption(value: CassetteTapeType.typeIVMetal, label: 'Type IV Metal'),
                RockerOption(value: CassetteTapeType.microCassette, label: 'Micro Lo-Fi'),
              ],
              selectedValue: settings.tapeType,
              activeColor: AppColors.kappogyYellow,
              onSelected: notifier.setTapeType,
            ),
          ),

          const SizedBox(height: 18),

          // Potentiometers (Wow/Flutter, Tape Wear, Magnetic Bias)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Tooltip(
                message: 'Analog motor speed wobble and pitch drift',
                child: SkeuoKnob(
                  label: 'WOW/FLUTTER',
                  value: settings.wowFlutterPercent,
                  min: 0.0,
                  max: 100.0,
                  size: 64,
                  ledColor: AppColors.kappogyYellow,
                  onChanged: settings.isEnabled ? notifier.setWowFlutter : (_) {},
                  displayValue: '${settings.wowFlutterPercent.toInt()}%',
                ),
              ),
              Tooltip(
                message: 'Magnetic particle age wear and high-frequency roll-off',
                child: SkeuoKnob(
                  label: 'TAPE WEAR',
                  value: settings.tapeWearPercent,
                  min: 0.0,
                  max: 100.0,
                  size: 64,
                  ledColor: AppColors.kappogyRed,
                  onChanged: settings.isEnabled ? notifier.setTapeWear : (_) {},
                  displayValue: '${settings.tapeWearPercent.toInt()}%',
                ),
              ),
              Tooltip(
                message: 'Record head magnetic bias saturation boost',
                child: SkeuoKnob(
                  label: 'BIAS GAIN',
                  value: settings.motorBiasGainDb,
                  min: 0.0,
                  max: 12.0,
                  size: 64,
                  ledColor: AppColors.ledCyan,
                  onChanged: settings.isEnabled ? notifier.setBias : (_) {},
                  displayValue: '+${settings.motorBiasGainDb.toStringAsFixed(1)}dB',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CassetteSpoolsPainter extends CustomPainter {
  final bool isEnabled;
  final double angle;

  _CassetteSpoolsPainter({required this.isEnabled, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Cassette shell window
    final windowPaint = Paint()..color = AppColors.panelSunken;
    final windowRect = RRect.fromRectAndRadius(Rect.fromLTWH(width * 0.1, 0, width * 0.8, height), const Radius.circular(8));
    canvas.drawRRect(windowRect, windowPaint);

    final leftCenter = Offset(width * 0.32, height / 2);
    final rightCenter = Offset(width * 0.68, height / 2);

    // Left & Right spool tape cakes
    final cakePaint = Paint()..color = const Color(0xFF332014);
    canvas.drawCircle(leftCenter, 22, cakePaint);
    canvas.drawCircle(rightCenter, 18, cakePaint);

    // Connecting tape ribbon
    final tapeLinePaint = Paint()
      ..color = const Color(0xFF452D1D)
      ..strokeWidth = 3.5;
    canvas.drawLine(Offset(leftCenter.dx, leftCenter.dy + 22), Offset(rightCenter.dx, rightCenter.dy + 18), tapeLinePaint);

    // Rotating Cog Hubs
    _drawSpoolCog(canvas, leftCenter, isEnabled ? angle : 0.0);
    _drawSpoolCog(canvas, rightCenter, isEnabled ? angle : 0.0);
  }

  void _drawSpoolCog(Canvas canvas, Offset center, double rot) {
    final whitePaint = Paint()..color = AppColors.textPrimary;
    canvas.drawCircle(center, 12, whitePaint);

    final innerPaint = Paint()..color = AppColors.panelSunken;
    canvas.drawCircle(center, 7, innerPaint);

    // 6 Spool Teeth
    final toothPaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.0;
    for (int i = 0; i < 6; i++) {
      final a = rot + (i * math.pi / 3);
      final p1 = Offset(center.dx + 6 * math.cos(a), center.dy + 6 * math.sin(a));
      final p2 = Offset(center.dx + 11 * math.cos(a), center.dy + 11 * math.sin(a));
      canvas.drawLine(p1, p2, toothPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CassetteSpoolsPainter oldDelegate) {
    return oldDelegate.isEnabled != isEnabled || oldDelegate.angle != angle;
  }
}
