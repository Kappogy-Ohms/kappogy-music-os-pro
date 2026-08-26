import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../data/duplicate_detective_service.dart';
import 'library_providers.dart';

class DuplicateCleanerDialog extends ConsumerStatefulWidget {
  const DuplicateCleanerDialog({super.key});

  @override
  ConsumerState<DuplicateCleanerDialog> createState() => _DuplicateCleanerDialogState();
}

class _DuplicateCleanerDialogState extends ConsumerState<DuplicateCleanerDialog> {
  List<DuplicateGroup>? _duplicates;

  @override
  void initState() {
    super.initState();
    _scanForDuplicates();
  }

  void _scanForDuplicates() {
    final tracks = ref.read(libraryNotifierProvider).value ?? [];
    final res = DuplicateDetectiveService.instance.findDuplicates(tracks);
    setState(() => _duplicates = res);
  }

  @override
  Widget build(BuildContext context) {
    final duplicates = _duplicates ?? [];
    int totalWastedBytes = 0;
    for (final group in duplicates) {
      for (final track in group.redundantTracks) {
        totalWastedBytes += track.fileSize;
      }
    }

    return Dialog(
      backgroundColor: AppColors.chassisBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.panelSunken,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: SkeuoTokens.sunkenWell,
                      ),
                      child: const Icon(Icons.cleaning_services_rounded, color: AppColors.kappogyYellow, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'DUPLICATE DETECTIVE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Health Status Banner
            SkeuoPanel(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    duplicates.isEmpty ? Icons.verified_rounded : Icons.warning_amber_rounded,
                    color: duplicates.isEmpty ? AppColors.kappogyGreen : AppColors.kappogyYellow,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          duplicates.isEmpty ? 'LIBRARY CLEAN & OPTIMIZED' : '${duplicates.length} DUPLICATE SETS DETECTED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: duplicates.isEmpty ? AppColors.kappogyGreen : AppColors.kappogyYellow,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          duplicates.isEmpty
                              ? 'All audio files in your local database are unique.'
                              : 'Potential space recovery: ${DurationFormatter.formatFileSize(totalWastedBytes)}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Duplicates List
            Expanded(
              child: duplicates.isEmpty
                  ? const Center(
                      child: Text(
                        'No duplicate audio files found in library.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      itemCount: duplicates.length,
                      itemBuilder: (ctx, idx) {
                        final group = duplicates[idx];
                        final best = group.bestQualityTrack;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.panelWell,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                            boxShadow: SkeuoTokens.sunkenWell,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      group.normalizedKey.toUpperCase(),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.panelSunken,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('${group.tracks.length} copies', style: const TextStyle(fontSize: 9, color: AppColors.kappogyYellow)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Recommended master: ${best.codec} (${best.bitrate} kbps, ${DurationFormatter.formatFileSize(best.fileSize)})',
                                style: const TextStyle(fontSize: 10, color: AppColors.kappogyGreen, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 10),

            // Bottom Action
            SizedBox(
              width: double.infinity,
              height: 42,
              child: SkeuoButton(
                size: 42,
                isCircular: false,
                activeColor: AppColors.kappogyGreen,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('DONE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
