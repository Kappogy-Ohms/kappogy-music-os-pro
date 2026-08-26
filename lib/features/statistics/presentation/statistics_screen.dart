import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../library/presentation/library_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryNotifierProvider).value ?? [];
    final totalTracks = library.length;
    final totalPlayCount = library.fold(0, (sum, t) => sum + t.playCount);
    final totalSkipCount = library.fold(0, (sum, t) => sum + t.skipCount);
    final totalDurationHours = library.fold(0, (sum, t) => sum + t.durationMs) / (1000 * 3600);

    return Scaffold(
      backgroundColor: AppColors.chassisBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SkeuoButton(
          size: 40,
          isCircular: false,
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'OFFLINE LISTENING ANALYTICS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
            shadows: SkeuoTokens.debossedText,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // High-Level KPI Tiles
              Row(
                children: [
                  Expanded(
                    child: _AnalyticsCard(
                      label: 'TOTAL SONGS',
                      value: '$totalTracks',
                      icon: Icons.music_note_rounded,
                      color: AppColors.ledCyan,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AnalyticsCard(
                      label: 'LIBRARY HOURS',
                      value: '${totalDurationHours.toStringAsFixed(1)}h',
                      icon: Icons.timer_rounded,
                      color: AppColors.kappogyYellow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _AnalyticsCard(
                      label: 'PLAYS RECORDED',
                      value: '$totalPlayCount',
                      icon: Icons.play_circle_filled_rounded,
                      color: AppColors.kappogyGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AnalyticsCard(
                      label: 'SKIPS',
                      value: '$totalSkipCount',
                      icon: Icons.skip_next_rounded,
                      color: AppColors.kappogyRed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Weekly Listening Distribution Chart
              SkeuoPanel(
                showCornerScrews: true,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WEEKLY LISTENING FREQUENCY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 20,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                  final idx = val.toInt();
                                  if (idx >= 0 && idx < days.length) {
                                    return Text(
                                      days[idx],
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            _makeBarGroup(0, 12, AppColors.kappogyRed),
                            _makeBarGroup(1, 15, AppColors.kappogyYellow),
                            _makeBarGroup(2, 8, AppColors.kappogyGreen),
                            _makeBarGroup(3, 18, AppColors.ledCyan),
                            _makeBarGroup(4, 14, AppColors.ledPurple),
                            _makeBarGroup(5, 19, AppColors.kappogyYellow),
                            _makeBarGroup(6, 11, AppColors.kappogyRed),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Most Played Artists
              const Text(
                'MOST PLAYED STUDIO ARTISTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              ...library.take(5).map((track) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.panelRaised,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                    boxShadow: SkeuoTokens.raisedSm,
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.panelSunken,
                        boxShadow: SkeuoTokens.sunkenWell,
                      ),
                      child: const Center(
                        child: Text(
                          'Ω',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.kappogyYellow),
                        ),
                      ),
                    ),
                    title: Text(
                      track.artist,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      '${track.playCount} plays • ${track.genre}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    trailing: Text(
                      '${track.bpm.round()} BPM',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ledCyan),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 14,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: AppColors.panelSunken,
          ),
        ),
      ],
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panelRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
        boxShadow: SkeuoTokens.raisedSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
              shadows: SkeuoTokens.debossedText,
            ),
          ),
        ],
      ),
    );
  }
}
