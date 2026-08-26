import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../data/auto_eq_database.dart';
import 'equalizer_providers.dart';
import 'parametric_peq_sheet.dart';

class AutoEqSheet extends ConsumerStatefulWidget {
  const AutoEqSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AutoEqSheet(),
    );
  }

  @override
  ConsumerState<AutoEqSheet> createState() => _AutoEqSheetState();
}

class _AutoEqSheetState extends ConsumerState<AutoEqSheet> {
  String _selectedBrand = 'ALL';
  AutoEqProfile _selectedProfile = AutoEqDatabase.profiles.first;

  @override
  Widget build(BuildContext context) {
    final brands = ['ALL', ...AutoEqDatabase.profiles.map((p) => p.brand).toSet()];
    final filtered = _selectedBrand == 'ALL'
        ? AutoEqDatabase.profiles
        : AutoEqDatabase.profiles.where((p) => p.brand == _selectedBrand).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: AppColors.chassisBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: SkeuoTokens.raisedLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.headphones_rounded, color: AppColors.ledCyan, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'AUDIOPHILE AUTOEQ CORRECTION SUITE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SkeuoButton(
                  size: 32,
                  icon: Icons.close_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: brands.map((b) {
                        final isSel = _selectedBrand == b;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedBrand = b),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.ledCyan.withValues(alpha: 0.15) : AppColors.panelRaised,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSel ? AppColors.ledCyan : AppColors.borderSubtle,
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                b,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: isSel ? AppColors.ledCyan : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Profile Selector Dropdown / Carousel
                  SkeuoPanel(
                    padding: const EdgeInsets.all(12),
                    showCornerScrews: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedProfile.brand.toUpperCase(),
                                  style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.textMuted),
                                ),
                                Text(
                                  _selectedProfile.model,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.panelWell,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _selectedProfile.type,
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.kappogyGreen),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Frequency Compensation Visualizer Spline
                        Container(
                          height: 70,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.panelWell,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                          ),
                          child: CustomPaint(
                            painter: _AutoEqCurvePainter(gains: _selectedProfile.graphic10BandGains),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedProfile.description,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Quick Action Apply Buttons
                  Row(
                    children: [
                      // Apply to 10-Band Graphic EQ
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.panelRaised,
                              side: const BorderSide(color: AppColors.ledCyan, width: 1.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.equalizer_rounded, color: AppColors.ledCyan, size: 16),
                            label: const Text(
                              'APPLY 10-BAND EQ',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            onPressed: () {
                              ref.read(equalizerNotifierProvider.notifier).setAllBands(
                                _selectedProfile.graphic10BandGains,
                                presetName: _selectedProfile.model,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Applied AutoEQ target to 10-Band EQ (${_selectedProfile.model})'),
                                  backgroundColor: AppColors.ledCyan,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Apply to 5-Band Parametric PEQ
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.panelRaised,
                              side: const BorderSide(color: AppColors.kappogyGreen, width: 1.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.show_chart_rounded, color: AppColors.kappogyGreen, size: 16),
                            label: const Text(
                              'APPLY 5-BAND PEQ',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            onPressed: () {
                              final peqNotifier = ref.read(parametricPeqProvider.notifier);
                              for (int i = 0; i < 5; i++) {
                                final f = _selectedProfile.peqFilters[i];
                                peqNotifier.updateBand(i, frequency: f.freq, gain: f.gain, q: f.q);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Applied Parametric PEQ filters for ${_selectedProfile.model}'),
                                  backgroundColor: AppColors.kappogyGreen,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'HEADPHONE & IEM MODEL TARGET PROFILES',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 8),

                  // Profile List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, idx) {
                      final p = filtered[idx];
                      final isSelected = _selectedProfile.id == p.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedProfile = p),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.panelRaised : AppColors.chassisBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.ledCyan : AppColors.borderSubtle,
                              width: isSelected ? 1.5 : 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                p.type.contains('IEM') ? Icons.earbuds_rounded : Icons.headphones_rounded,
                                color: isSelected ? AppColors.ledCyan : AppColors.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.model,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? AppColors.ledCyan : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${p.brand} • ${p.type}',
                                      style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: AppColors.ledCyan, size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoEqCurvePainter extends CustomPainter {
  final List<double> gains;
  _AutoEqCurvePainter({required this.gains});

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;

    // Grid center line (0dB reference)
    final gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), gridPaint);

    if (gains.isEmpty) return;

    final path = Path();
    final stepX = size.width / (gains.length - 1);

    final points = <Offset>[];
    for (int i = 0; i < gains.length; i++) {
      final x = i * stepX;
      // -12dB to +12dB mapped to height
      final y = midY - (gains[i] / 6.0) * (size.height * 0.40);
      points.add(Offset(x, y.clamp(4.0, size.height - 4.0)));
    }

    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final curvePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = const Color(0xFF00E5FF);

    canvas.drawPath(path, curvePaint);

    // Draw dots on nodes
    final dotPaint = Paint()..color = const Color(0xFF00E5FF);
    for (final p in points) {
      canvas.drawCircle(p, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AutoEqCurvePainter oldDelegate) => true;
}
