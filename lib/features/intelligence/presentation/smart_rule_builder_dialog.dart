import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../library/presentation/library_providers.dart';

class SmartRuleBuilderDialog extends ConsumerStatefulWidget {
  const SmartRuleBuilderDialog({super.key});

  @override
  ConsumerState<SmartRuleBuilderDialog> createState() => _SmartRuleBuilderDialogState();
}

class _SmartRuleBuilderDialogState extends ConsumerState<SmartRuleBuilderDialog> {
  final TextEditingController _nameController = TextEditingController(text: 'High Energy Afrobeats');
  double _minBpm = 110.0;
  double _maxBpm = 135.0;
  double _minRating = 4.0;
  String _selectedGenre = 'Any';
  bool _onlyFavorites = false;
  final int _limit = 25;

  final List<String> _genres = ['Any', 'Afrobeats', 'Synthwave', 'Gospel', 'Hip-Hop', 'House', 'Pop', 'Electronic'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.chassisBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.panelSunken,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: SkeuoTokens.sunkenWell,
                    ),
                    child: const Icon(Icons.psychology_rounded, color: AppColors.ledCyan, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'BUILD SMART PLAYLIST RULE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Playlist Name
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'PLAYLIST NAME',
                  labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.panelWell,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 12),

              // BPM Range Slider
              SkeuoPanel(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TEMPO RANGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                        Text('${_minBpm.round()} - ${_maxBpm.round()} BPM', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.ledCyan)),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(_minBpm, _maxBpm),
                      min: 60,
                      max: 180,
                      activeColor: AppColors.ledCyan,
                      inactiveColor: AppColors.panelSunken,
                      onChanged: (vals) {
                        setState(() {
                          _minBpm = vals.start;
                          _maxBpm = vals.end;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Genre Dropdown & Min Rating
              Row(
                children: [
                  Expanded(
                    child: SkeuoPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GENRE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                          DropdownButton<String>(
                            value: _selectedGenre,
                            dropdownColor: AppColors.chassisBg,
                            isExpanded: true,
                            underline: const SizedBox(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            items: _genres.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedGenre = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SkeuoPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('MIN RATING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(5, (idx) {
                              return GestureDetector(
                                onTap: () => setState(() => _minRating = (idx + 1).toDouble()),
                                child: Icon(
                                  idx < _minRating ? Icons.star_rounded : Icons.star_border_rounded,
                                  color: idx < _minRating ? AppColors.kappogyYellow : AppColors.textMuted,
                                  size: 18,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Only Favorites Switch & Limit
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('FAVORITES ONLY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      value: _onlyFavorites,
                      activeColor: AppColors.kappogyRed,
                      onChanged: (v) => setState(() => _onlyFavorites = v ?? false),
                    ),
                  ),
                  Text('LIMIT: $_limit', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                ],
              ),

              const SizedBox(height: 14),

              // Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  SkeuoButton(
                    size: 38,
                    isCircular: false,
                    activeColor: AppColors.kappogyGreen,
                    onPressed: _createSmartPlaylist,
                    child: const Text(
                      'GENERATE PLAYLIST',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createSmartPlaylist() async {
    final title = _nameController.text.trim().isEmpty ? 'Smart Playlist' : _nameController.text.trim();
    final allTracks = ref.read(libraryNotifierProvider).value ?? [];

    final matchingTracks = allTracks.where((t) {
      if (t.bpm < _minBpm || t.bpm > _maxBpm) return false;
      if (_selectedGenre != 'Any' && !t.genre.toLowerCase().contains(_selectedGenre.toLowerCase())) return false;
      if (t.rating < _minRating) return false;
      if (_onlyFavorites && !t.isFavorite) return false;
      return true;
    }).take(_limit).toList();

    if (matchingTracks.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tracks match this criteria. Try broadening tempo or genre.'),
          backgroundColor: AppColors.kappogyRed,
        ),
      );
      return;
    }

    final newPlaylist = await ref.read(playlistsNotifierProvider.notifier).createPlaylist(title);
    for (final track in matchingTracks) {
      await ref.read(playlistsNotifierProvider.notifier).addTrackToPlaylist(newPlaylist.id, track.id);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Created smart playlist "$title" with ${matchingTracks.length} tracks!'),
        backgroundColor: AppColors.kappogyGreen,
      ),
    );
  }
}
