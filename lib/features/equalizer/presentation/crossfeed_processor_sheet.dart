import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';

enum AcousticRoomSpace {
  dryStudio('Dry Studio Monitor', 'Direct nearfield response with zero reverberant reflections'),
  controlRoom('Analog Control Room', 'Balanced studio treatment with warm analog desk reflections'),
  acousticChamber('Acoustic Chamber', 'Open wooden studio chamber with rich spatial decay'),
  liveStage('Live Concert Stage', 'Expansive soundstage width with deep psychoacoustic immersion');

  final String label;
  final String description;
  const AcousticRoomSpace(this.label, this.description);
}

class CrossfeedSettings {
  final bool isEnabled;
  final double blendPercent; // 0.0 to 1.0 (Bauer ITD blend)
  final double hfDampingDb; // -6.0 to 0.0 dB
  final bool isSubBassMono; // Mono sum below 90Hz
  final AcousticRoomSpace roomSpace;
  final double delayMicroseconds; // 250 to 450 us

  const CrossfeedSettings({
    this.isEnabled = true,
    this.blendPercent = 0.45,
    this.hfDampingDb = -3.5,
    this.isSubBassMono = true,
    this.roomSpace = AcousticRoomSpace.controlRoom,
    this.delayMicroseconds = 320.0,
  });

  CrossfeedSettings copyWith({
    bool? isEnabled,
    double? blendPercent,
    double? hfDampingDb,
    bool? isSubBassMono,
    AcousticRoomSpace? roomSpace,
    double? delayMicroseconds,
  }) {
    return CrossfeedSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      blendPercent: blendPercent ?? this.blendPercent,
      hfDampingDb: hfDampingDb ?? this.hfDampingDb,
      isSubBassMono: isSubBassMono ?? this.isSubBassMono,
      roomSpace: roomSpace ?? this.roomSpace,
      delayMicroseconds: delayMicroseconds ?? this.delayMicroseconds,
    );
  }
}

class CrossfeedNotifier extends StateNotifier<CrossfeedSettings> {
  CrossfeedNotifier() : super(const CrossfeedSettings());

  void toggleEnabled() => state = state.copyWith(isEnabled: !state.isEnabled);
  void setBlend(double val) => state = state.copyWith(blendPercent: val.clamp(0.0, 1.0));
  void setHfDamping(double val) => state = state.copyWith(hfDampingDb: val.clamp(-6.0, 0.0));
  void toggleSubBassMono() => state = state.copyWith(isSubBassMono: !state.isSubBassMono);
  void setRoomSpace(AcousticRoomSpace space) => state = state.copyWith(roomSpace: space);
  void setDelay(double us) => state = state.copyWith(delayMicroseconds: us.clamp(200.0, 500.0));
}

final crossfeedProvider = StateNotifierProvider<CrossfeedNotifier, CrossfeedSettings>((ref) {
  return CrossfeedNotifier();
});

/// Headphone Crossfeed & Acoustic Room Processor Sheet
class CrossfeedProcessorSheet extends ConsumerWidget {
  const CrossfeedProcessorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const CrossfeedProcessorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(crossfeedProvider);
    final notifier = ref.read(crossfeedProvider.notifier);

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
                  Icon(Icons.headphones_rounded, color: AppColors.ledCyan, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'BAUER HEADPHONE CROSSFEED & ROOM PROCESSOR',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Tooltip(
                message: 'Toggle Crossfeed Processor Bypass',
                child: SkeuoButton(
                  size: 32,
                  activeColor: AppColors.kappogyGreen,
                  isActive: settings.isEnabled,
                  onPressed: notifier.toggleEnabled,
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    size: 16,
                    color: settings.isEnabled ? AppColors.kappogyGreen : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Stereo Field Soundstage Visualizer
          SkeuoPanel(
            showCornerScrews: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('VIRTUAL SOUNDSTAGE FIELD (ITD / IID)', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                    Text(
                      settings.isEnabled ? '${(settings.blendPercent * 100).toInt()}% BLEND • ${settings.delayMicroseconds.toInt()}μs ITD' : 'BYPASS',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: settings.isEnabled ? AppColors.ledCyan : AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomPaint(
                  size: const Size(double.infinity, 50),
                  painter: _StereoFieldPainter(
                    isEnabled: settings.isEnabled,
                    blend: settings.blendPercent,
                    room: settings.roomSpace,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Room Space Rocker Switch
          const Text('ACOUSTIC ROOM SPACE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SkeuoRockerSwitch<AcousticRoomSpace>(
              options: const [
                RockerOption(value: AcousticRoomSpace.dryStudio, label: 'Dry Studio'),
                RockerOption(value: AcousticRoomSpace.controlRoom, label: 'Control Room'),
                RockerOption(value: AcousticRoomSpace.acousticChamber, label: 'Chamber'),
                RockerOption(value: AcousticRoomSpace.liveStage, label: 'Live Stage'),
              ],
              selectedValue: settings.roomSpace,
              activeColor: AppColors.ledCyan,
              onSelected: notifier.setRoomSpace,
            ),
          ),

          const SizedBox(height: 18),

          // Hardware Rotary Potentiometers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Tooltip(
                message: 'Adjust Bauer crossfeed mix between left & right stereo channels to eliminate ear fatigue',
                child: SkeuoKnob(
                  label: 'CROSSFEED',
                  value: settings.blendPercent * 100.0,
                  min: 0.0,
                  max: 100.0,
                  size: 64,
                  ledColor: AppColors.ledCyan,
                  onChanged: settings.isEnabled ? (v) => notifier.setBlend(v / 100.0) : (_) {},
                  displayValue: '${(settings.blendPercent * 100).toInt()}%',
                ),
              ),
              Tooltip(
                message: 'High frequency acoustic head-shadow attenuation',
                child: SkeuoKnob(
                  label: 'HF SHADOW',
                  value: settings.hfDampingDb,
                  min: -6.0,
                  max: 0.0,
                  size: 64,
                  ledColor: AppColors.kappogyYellow,
                  onChanged: settings.isEnabled ? notifier.setHfDamping : (_) {},
                  displayValue: '${settings.hfDampingDb.toStringAsFixed(1)}dB',
                ),
              ),
              Tooltip(
                message: 'Interaural Time Delay simulation between left & right ear',
                child: SkeuoKnob(
                  label: 'ITD DELAY',
                  value: settings.delayMicroseconds,
                  min: 200.0,
                  max: 500.0,
                  size: 64,
                  ledColor: AppColors.kappogyGreen,
                  onChanged: settings.isEnabled ? notifier.setDelay : (_) {},
                  displayValue: '${settings.delayMicroseconds.toInt()}μs',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sub-Bass Mono Summing Switch
          SkeuoPanel(
            showCornerScrews: false,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SUB-BASS MONO SUMMING (< 90Hz)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('Centers low-end energy for punchy vinyl master clarity', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                  ],
                ),
                Tooltip(
                  message: 'Sum sub-bass frequencies below 90Hz to center mono',
                  child: SkeuoButton(
                    size: 34,
                    activeColor: AppColors.kappogyYellow,
                    isActive: settings.isSubBassMono,
                    onPressed: notifier.toggleSubBassMono,
                    child: Icon(
                      Icons.speaker_rounded,
                      size: 16,
                      color: settings.isSubBassMono ? AppColors.kappogyYellow : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StereoFieldPainter extends CustomPainter {
  final bool isEnabled;
  final double blend;
  final AcousticRoomSpace room;

  _StereoFieldPainter({required this.isEnabled, required this.blend, required this.room});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width;
    final height = size.height;

    // Background center grid
    final gridPaint = Paint()
      ..color = AppColors.borderSubtle.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, height / 2), Offset(width, height / 2), gridPaint);
    canvas.drawLine(Offset(width / 2, 0), Offset(width / 2, height), gridPaint);

    // Left & Right Soundstage dispersion arcs
    final leftX = isEnabled ? (width * 0.28) + (blend * width * 0.12) : width * 0.15;
    final rightX = isEnabled ? (width * 0.72) - (blend * width * 0.12) : width * 0.85;

    final dispersionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (isEnabled) {
      dispersionPaint.color = AppColors.ledCyan.withValues(alpha: 0.85);
      canvas.drawCircle(Offset(leftX, height / 2), 16, dispersionPaint);
      canvas.drawCircle(Offset(rightX, height / 2), 16, dispersionPaint);

      // Room ambient aura
      final auraPaint = Paint()
        ..color = AppColors.kappogyYellow.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: center, width: (rightX - leftX) + 60, height: 32), auraPaint);
    } else {
      dispersionPaint.color = AppColors.textMuted.withValues(alpha: 0.5);
      canvas.drawCircle(Offset(leftX, height / 2), 12, dispersionPaint);
      canvas.drawCircle(Offset(rightX, height / 2), 12, dispersionPaint);
    }

    // Center listener head icon
    final listenerPaint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.5, listenerPaint);
  }

  @override
  bool shouldRepaint(covariant _StereoFieldPainter oldDelegate) {
    return oldDelegate.isEnabled != isEnabled || oldDelegate.blend != blend || oldDelegate.room != room;
  }
}
