import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../audio_player/domain/track_model.dart';
import '../../library/data/music_database.dart';
import '../../library/presentation/library_providers.dart';

class TagEditorSheet extends ConsumerStatefulWidget {
  final Track track;

  const TagEditorSheet({super.key, required this.track});

  @override
  ConsumerState<TagEditorSheet> createState() => _TagEditorSheetState();
}

class _TagEditorSheetState extends ConsumerState<TagEditorSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _artistCtrl;
  late TextEditingController _albumCtrl;
  late TextEditingController _genreCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _trackNumCtrl;
  late int _rating;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.track.title);
    _artistCtrl = TextEditingController(text: widget.track.artist);
    _albumCtrl = TextEditingController(text: widget.track.album);
    _genreCtrl = TextEditingController(text: widget.track.genre);
    _yearCtrl = TextEditingController(text: widget.track.year.toString());
    _trackNumCtrl = TextEditingController(text: widget.track.trackNumber.toString());
    _rating = widget.track.rating;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    _albumCtrl.dispose();
    _genreCtrl.dispose();
    _yearCtrl.dispose();
    _trackNumCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveTags() async {
    final db = MusicDatabase.instance;
    final updatedMap = {
      'title': _titleCtrl.text.trim(),
      'artist': _artistCtrl.text.trim(),
      'album': _albumCtrl.text.trim(),
      'genre': _genreCtrl.text.trim(),
      'year': int.tryParse(_yearCtrl.text) ?? widget.track.year,
      'track_number': int.tryParse(_trackNumCtrl.text) ?? widget.track.trackNumber,
      'rating': _rating,
    };

    await db.updateMetadata(widget.track.id, updatedMap);
    await ref.read(libraryNotifierProvider.notifier).loadLibrary();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Metadata saved to local database successfully.'),
          backgroundColor: AppColors.kappogyGreen,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.chassisBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'STUDIO ID3 METADATA EDITOR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: 1.0,
                  ),
                ),
                SkeuoButton(
                  size: 32,
                  icon: Icons.close_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _buildField('TRACK TITLE', _titleCtrl),
            const SizedBox(height: 10),
            _buildField('ARTIST / PERFORMER', _artistCtrl),
            const SizedBox(height: 10),
            _buildField('ALBUM', _albumCtrl),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _buildField('GENRE', _genreCtrl)),
                const SizedBox(width: 10),
                Expanded(child: _buildField('YEAR', _yearCtrl)),
                const SizedBox(width: 10),
                Expanded(child: _buildField('TRACK #', _trackNumCtrl)),
              ],
            ),

            const SizedBox(height: 14),

            // Rating Stars
            SkeuoPanel(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RATING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (idx) {
                      final starVal = idx + 1;
                      return IconButton(
                        icon: Icon(
                          starVal <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: starVal <= _rating ? AppColors.kappogyYellow : AppColors.textMuted,
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() => _rating = starVal);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Save Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kappogyRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                ),
                onPressed: _saveTags,
                child: const Text(
                  'SAVE METADATA TO DATABASE',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.panelWell,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            boxShadow: SkeuoTokens.sunkenWell,
          ),
          child: TextField(
            controller: ctrl,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
          ),
        ),
      ],
    );
  }
}
