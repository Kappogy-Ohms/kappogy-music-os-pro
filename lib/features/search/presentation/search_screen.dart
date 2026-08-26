import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../audio_player/domain/track_model.dart';
import '../../audio_player/presentation/audio_providers.dart';
import '../../library/data/music_database.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Track> _searchResults = [];
  bool _isLoading = false;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _performSearch('');
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    final db = MusicDatabase.instance;
    String effectiveQuery = query;

    if (_selectedFilter != 'ALL' && query.isNotEmpty) {
      if (_selectedFilter == 'ARTIST') effectiveQuery = 'artist:$query';
      if (_selectedFilter == 'GENRE') effectiveQuery = 'genre:$query';
      if (_selectedFilter == 'BPM') effectiveQuery = 'bpm:$query';
    }

    final results = await db.searchTracks(effectiveQuery);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playbackNotifier = ref.read(playbackStateProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.chassisBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'INSTANT LOCAL SEARCH',
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
        child: Column(
          children: [
            // Search Input Well
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.panelWell,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: SkeuoTokens.sunkenWell,
                  border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => _performSearch(val),
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists, albums, or "bpm:90-120"...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    icon: const Icon(Icons.search_rounded, color: AppColors.ledCyan),
                    border: InputBorder.none,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Quick Filter Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: ['ALL', 'ARTIST', 'GENRE', 'BPM', 'FAVORITES'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedFilter = filter);
                        _performSearch(_searchController.text);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.panelSunken : AppColors.panelRaised,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.ledCyan : AppColors.borderSubtle,
                            width: 1.0,
                          ),
                          boxShadow: isSelected ? SkeuoTokens.pressedDepth : SkeuoTokens.raisedSm,
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? AppColors.ledCyan : AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // Search Results List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.kappogyRed))
                  : _searchResults.isEmpty
                      ? const Center(
                          child: Text(
                            'No tracks found matching query',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, idx) {
                            final track = _searchResults[idx];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.panelRaised,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                                boxShadow: SkeuoTokens.raisedSm,
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.panelSunken,
                                    boxShadow: SkeuoTokens.sunkenWell,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Ω',
                                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.kappogyYellow),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  track.title,
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${track.artist} • ${track.album} • ${track.bpm.round()} BPM',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DurationFormatter.format(track.duration),
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                    const SizedBox(width: 8),
                                    SkeuoButton(
                                      size: 34,
                                      icon: Icons.play_arrow_rounded,
                                      onPressed: () {
                                        playbackNotifier.playTrack(track, _searchResults);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
