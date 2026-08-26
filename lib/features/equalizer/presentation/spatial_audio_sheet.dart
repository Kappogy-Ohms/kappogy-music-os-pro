import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';

enum SpatialHrtfProfile {
  genericStudio('Studio HRTF', 'Accurate binaural head-related transfer function with localized imaging'),
  nearfieldMonitor('Nearfield Desk', 'Direct acoustic monitoring with subtle baffle reflections'),
  binauralCinema('Binaural Cinema', 'Expansive 3D immersive sphere with surround depth'),
  expansiveArena('Stadium Arena', 'Grand concert hall dispersion with wide spatial reflection decay');

  final String label;
  final String description;
  const SpatialHrtfProfile(this.label, this.description);
}

class SpatialAudioSettings {
  final bool isEnabled;
  final SpatialHrtfProfile profile;
  final double azimuthDegrees; // 0.0 to 360.0 degrees
  final double elevationDegrees; // -45.0 to +45.0 degrees
  final double distanceMeters; // 0.5 to 10.0 meters
  final bool isRoomReflectionEnabled;

  const SpatialAudioSettings({
    this.isEnabled = true,
    this.profile = SpatialHrtfProfile.genericStudio,
    this.azimuthDegrees = 45.0,
    this.elevationDegrees = 10.0,
    this.distanceMeters = 2.0,
    this.isRoomReflectionEnabled = true,
  });

  SpatialAudioSettings copyWith({
    bool? isEnabled,
    SpatialHrtfProfile? profile,
    double? azimuthDegrees,
    double? elevationDegrees,
    double? distanceMeters,
    bool? isRoomReflectionEnabled,
  }) {
    return SpatialAudioSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      profile: profile ?? this.profile,
      azimuthDegrees: azimuthDegrees ?? this.azimuthDegrees,
      elevationDegrees: elevationDegrees ?? this.elevationDegrees,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isRoomReflectionEnabled: isRoomReflectionEnabled ?? this.isRoomReflectionEnabled,
    );
  }
}

class SpatialAudioNotifier extends StateNotifier<SpatialAudioSettings> {
  SpatialAudioNotifier() : super(const SpatialAudioSettings());

  void toggleEnabled() => state = state.copyWith(isEnabled: !state.isEnabled);
  void setProfile(SpatialHrtfProfile p) => state = state.copyWith(profile: p);
  void setAzimuth(double deg) => state = state.copyWith(azimuthDegrees: (deg % 360.0 + 360.0) % 360.0);
  void setElevation(double deg) => state = state.copyWith(elevationDegrees: deg.clamp(-45.0, 45.0));
  void setDistance(double meters) => state = state.copyWith(distanceMeters: meters.clamp(0.5, 10.0));
  void toggleRoomReflection() => state = state.copyWith(isRoomReflectionEnabled: !state.isRoomReflectionEnabled);
}

final spatialAudioProvider = StateNotifierProvider<SpatialAudioNotifier, SpatialAudioSettings>((ref) {
  return SpatialAudioNotifier();
});

class SpatialAudioSheet extends ConsumerWidget {
  const SpatialAudioSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SpatialAudioSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(spatialAudioProvider);
    final notifier = ref.read(spatialAudioProvider.notifier);

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
                  Icon(Icons.spatial_audio_off_rounded, color: AppColors.ledPurple, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'BINAURAL 3D SPATIAL AUDIO & ORBIT SIMULATOR',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Tooltip(
                message: 'Toggle 3D Spatial Audio Engine',
                child: SkeuoButton(
                  size: 32,
                  activeColor: AppColors.ledPurple,
                  isActive: settings.isEnabled,
                  onPressed: notifier.toggleEnabled,
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    size: 16,
                    color: settings.isEnabled ? AppColors.ledPurple : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Interactive 360° Spatial Radar Disk
          SkeuoPanel(
            showCornerScrews: false,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('360° SPATIAL ORBIT RADAR', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                    Text(
                      settings.isEnabled
                          ? '${settings.azimuthDegrees.toInt()}° AZIMUTH • ${settings.distanceMeters.toStringAsFixed(1)}m'
                          : 'BYPASS',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: settings.isEnabled ? AppColors.ledPurple : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onPanUpdate: settings.isEnabled
                        ? (details) {
                            final box = context.findRenderObject() as RenderBox?;
                            if (box == null) return;
                            final local = details.localPosition;
                            final center = const Offset(100, 75);
                            final dx = local.dx - center.dx;
                            final dy = local.dy - center.dy;
                            var angle = math.atan2(dy, dx) * 180 / math.pi + 90;
                            if (angle < 0) angle += 360;
                            notifier.setAzimuth(angle);
                          }
                        : null,
                    child: CustomPaint(
                      size: const Size(200, 150),
                      painter: _SpatialRadarPainter(
                        isEnabled: settings.isEnabled,
                        azimuth: settings.azimuthDegrees,
                        distance: settings.distanceMeters,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // HRTF Profile Rocker
          const Text('HRTF ACOUSTIC PROFILE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SkeuoRockerSwitch<SpatialHrtfProfile>(
              options: const [
                RockerOption(value: SpatialHrtfProfile.genericStudio, label: 'Studio HRTF'),
                RockerOption(value: SpatialHrtfProfile.nearfieldMonitor, label: 'Nearfield'),
                RockerOption(value: SpatialHrtfProfile.binauralCinema, label: 'Cinema 3D'),
                RockerOption(value: SpatialHrtfProfile.expansiveArena, label: 'Concert Hall'),
              ],
              selectedValue: settings.profile,
              activeColor: AppColors.ledPurple,
              onSelected: notifier.setProfile,
            ),
          ),

          const SizedBox(height: 18),

          // Knobs (Azimuth, Elevation, Distance)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Tooltip(
                message: 'Horizontal circular angle around head (0° to 360°)',
                child: SkeuoKnob(
                  label: 'AZIMUTH',
                  value: settings.azimuthDegrees,
                  min: 0.0,
                  max: 360.0,
                  size: 64,
                  ledColor: AppColors.ledPurple,
                  onChanged: settings.isEnabled ? notifier.setAzimuth : (_) {},
                  displayValue: '${settings.azimuthDegrees.toInt()}°',
                ),
              ),
              Tooltip(
                message: 'Vertical height angle above or below head (-45° to +45°)',
                child: SkeuoKnob(
                  label: 'ELEVATION',
                  value: settings.elevationDegrees,
                  min: -45.0,
                  max: 45.0,
                  size: 64,
                  ledColor: AppColors.ledCyan,
                  onChanged: settings.isEnabled ? notifier.setElevation : (_) {},
                  displayValue: '${settings.elevationDegrees >= 0 ? '+' : ''}${settings.elevationDegrees.toInt()}°',
                ),
              ),
              Tooltip(
                message: 'Perceived 3D distance from listener (0.5m to 10m)',
                child: SkeuoKnob(
                  label: 'DISTANCE',
                  value: settings.distanceMeters,
                  min: 0.5,
                  max: 10.0,
                  size: 64,
                  ledColor: AppColors.kappogyYellow,
                  onChanged: settings.isEnabled ? notifier.setDistance : (_) {},
                  displayValue: '${settings.distanceMeters.toStringAsFixed(1)}m',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpatialRadarPainter extends CustomPainter {
  final bool isEnabled;
  final double azimuth;
  final double distance;

  _SpatialRadarPainter({required this.isEnabled, required this.azimuth, required this.distance});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.45;

    // Concentric radar rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.borderSubtle.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, maxRadius * 0.33, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.66, ringPaint);
    canvas.drawCircle(center, maxRadius, ringPaint);

    // Crosshairs
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), ringPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), ringPaint);

    // Listener Head Icon in Center
    final headPaint = Paint()
      ..color = isEnabled ? AppColors.textPrimary : AppColors.textMuted
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, headPaint);

    // Nose pointer
    final nosePath = Path()
      ..moveTo(center.dx - 3, center.dy - 6)
      ..lineTo(center.dx, center.dy - 11)
      ..lineTo(center.dx + 3, center.dy - 6)
      ..close();
    canvas.drawPath(nosePath, headPaint);

    // Sound Source Orbit Position
    final rad = (azimuth - 90) * math.pi / 180.0;
    final normalizedDist = (distance / 10.0).clamp(0.25, 1.0) * maxRadius;
    final sourceX = center.dx + normalizedDist * math.cos(rad);
    final sourceY = center.dy + normalizedDist * math.sin(rad);
    final sourcePos = Offset(sourceX, sourceY);

    if (isEnabled) {
      // Glow trail
      final rayPaint = Paint()
        ..color = AppColors.ledPurple.withValues(alpha: 0.3)
        ..strokeWidth = 1.5;
      canvas.drawLine(center, sourcePos, rayPaint);

      final sourceGlowPaint = Paint()
        ..color = AppColors.ledPurple.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(sourcePos, 10, sourceGlowPaint);

      final sourceDotPaint = Paint()..color = AppColors.ledPurple;
      canvas.drawCircle(sourcePos, 6, sourceDotPaint);
    } else {
      final sourceDotPaint = Paint()..color = AppColors.textMuted;
      canvas.drawCircle(sourcePos, 5, sourceDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpatialRadarPainter oldDelegate) {
    return oldDelegate.isEnabled != isEnabled || oldDelegate.azimuth != azimuth || oldDelegate.distance != distance;
  }
}
