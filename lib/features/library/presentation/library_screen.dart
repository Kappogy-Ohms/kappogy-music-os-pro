import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_brand_logo.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';
import '../../audio_player/domain/track_model.dart';
import '../../audio_player/presentation/audio_providers.dart';
import '../../audio_player/presentation/mini_player_dock.dart';
import '../../audio_player/presentation/now_playing_screen.dart';
import '../../audio_player/presentation/ab_looper_sheet.dart';
import '../../audio_player/presentation/haptic_bass_sheet.dart';
import '../../audio_player/presentation/pitch_formant_lab_sheet.dart';
import '../../audio_player/presentation/ringtone_trimmer_dialog.dart';
import '../../audio_player/presentation/spectral_analyzer_dialog.dart';
import '../../audio_player/presentation/studio_synth_sheet.dart';
import '../../equalizer/presentation/analog_warmer_sheet.dart';
import '../../equalizer/presentation/cassette_deck_sheet.dart';
import '../../equalizer/presentation/crossfeed_processor_sheet.dart';
import '../../equalizer/presentation/equalizer_screen.dart';
import '../../equalizer/presentation/loudness_leveler_sheet.dart';
import '../../equalizer/presentation/parametric_peq_sheet.dart';
import '../../equalizer/presentation/spatial_audio_sheet.dart';
import '../../dj_mode/presentation/automix_engine_sheet.dart';
import '../../dj_mode/presentation/dj_console_screen.dart';
import '../../dj_mode/presentation/dj_pro_screen.dart';
import '../../dj_mode/presentation/dj_providers.dart';
import '../../dj_mode/presentation/stem_mixer_sheet.dart';
import '../../intelligence/presentation/ear_training_game_dialog.dart';
import '../../lyrics/presentation/lyrics_screen.dart';
import '../../lyrics/presentation/karaoke_hud_screen.dart';
import '../../lyrics/presentation/vocal_remover_sheet.dart';
import '../../metadata_editor/presentation/tag_editor_sheet.dart';
import '../../search/presentation/search_screen.dart';
import '../../intelligence/presentation/intelligence_dashboard.dart';
import '../../statistics/presentation/statistics_screen.dart';
import '../../backup_restore/presentation/backup_restore_screen.dart';
import '../../documentation/presentation/studio_guide_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import 'duplicate_cleaner_dialog.dart';
import '../domain/album_model.dart';
import '../domain/artist_model.dart';
import 'library_providers.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _activeTab = 'SONGS';
  final ScrollController _scrollController = ScrollController();

  Future<void> _pickAndScanFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scanning folder: $result...'),
          backgroundColor: AppColors.ledCyan,
        ),
      );
      await ref.read(libraryNotifierProvider.notifier).scanDirectory(result);
    }
  }

  void _openNowPlaying() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NowPlayingScreen(
          onOpenEqualizer: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EqualizerScreen())),
          onOpenDJMode: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DjConsoleScreen())),
          onOpenLyrics: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LyricsScreen())),
          onOpenTagEditor: () {
            final track = ref.read(playbackStateProvider).currentTrack;
            if (track != null) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => TagEditorSheet(track: track),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(libraryNotifierProvider);
    final albums = ref.watch(albumsProvider);
    final artists = ref.watch(artistsProvider);
    final favorites = ref.watch(favoriteTracksProvider);
    final playlistsAsync = ref.watch(playlistsNotifierProvider);
    final playbackNotifier = ref.read(playbackStateProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.chassisBg,
      appBar: AppBar(
        backgroundColor: AppColors.chassisBg,
        elevation: 0,
        title: const SkeuoBrandLogo(size: 32),
        actions: [
          SkeuoButton(
            size: 36,
            icon: Icons.search_rounded,
            tooltip: 'Instant Search',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
          const SizedBox(width: 8),
          SkeuoButton(
            size: 36,
            icon: Icons.create_new_folder_rounded,
            tooltip: 'Scan Music Directory',
            activeColor: AppColors.kappogyGreen,
            onPressed: _pickAndScanFolder,
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.raisedButtonGradient,
                border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                boxShadow: SkeuoTokens.raisedSm,
              ),
              child: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textPrimary),
            ),
            color: AppColors.chassisBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (val) {
              if (val == 'eq') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EqualizerScreen()));
              } else if (val == 'dj') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DjConsoleScreen()));
              } else if (val == 'dj_pro') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DjProScreen()));
              } else if (val == 'karaoke') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KaraokeHudScreen()));
              } else if (val == 'intelligence') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IntelligenceDashboard()));
              } else if (val == 'stats') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StatisticsScreen()));
              } else if (val == 'backup') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BackupRestoreScreen()));
              } else if (val == 'crossfeed') {
                CrossfeedProcessorSheet.show(context);
              } else if (val == 'lufs') {
                LoudnessLevelerSheet.show(context);
              } else if (val == 'warmer') {
                AnalogWarmerSheet.show(context);
              } else if (val == 'vocal') {
                VocalRemoverSheet.show(context);
              } else if (val == 'haptic') {
                HapticBassSheet.show(context);
              } else if (val == 'automix') {
                AutomixEngineSheet.show(context);
              } else if (val == 'spatial') {
                SpatialAudioSheet.show(context);
              } else if (val == 'cassette') {
                CassetteDeckSheet.show(context);
              } else if (val == 'synth') {
                StudioSynthSheet.show(context);
              } else if (val == 'stems') {
                StemMixerSheet.show(context);
              } else if (val == 'peq') {
                ParametricPeqSheet.show(context);
              } else if (val == 'pitch_lab') {
                PitchFormantLabSheet.show(context);
              } else if (val == 'ear_game') {
                EarTrainingGameDialog.show(context);
              } else if (val == 'looper') {
                AbLooperSheet.show(context);
              } else if (val == 'duplicates') {
                showDialog(context: context, builder: (_) => const DuplicateCleanerDialog());
              } else if (val == 'guide') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudioGuideScreen()));
              } else if (val == 'settings') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }
            },
            itemBuilder: (ctx) => [
              _menuItem('eq', 'Equalizer 10-Band Rack', Icons.equalizer_rounded),
              _menuItem('peq', '5-Band Parametric EQ (PEQ)', Icons.show_chart_rounded),
              _menuItem('crossfeed', 'Headphone Crossfeed & Room', Icons.headphones_rounded),
              _menuItem('spatial', 'Binaural 3D Spatial Audio', Icons.spatial_audio_off_rounded),
              _menuItem('lufs', 'EBU R128 Loudness Leveler', Icons.volume_up_rounded),
              _menuItem('warmer', 'Analog Tube & Tape Warmer', Icons.fireplace_rounded),
              _menuItem('cassette', 'Vintage Cassette Deck', Icons.album_rounded),
              _menuItem('stems', '4-Track Multi-Stem Mixer', Icons.tune_rounded),
              _menuItem('vocal', 'Vocal Remover & Extractor', Icons.mic_off_rounded),
              _menuItem('haptic', 'Tactile Haptic Bass Shaker', Icons.vibration_rounded),
              _menuItem('pitch_lab', 'Pitch & Formant Lab', Icons.speed_rounded),
              _menuItem('synth', 'Studio Synth & Tone Gen', Icons.piano_rounded),
              _menuItem('ear_game', 'Musician Ear Training Game', Icons.psychology_rounded),
              _menuItem('automix', 'DJ Automix & Radio Engine', Icons.auto_mode_rounded),
              _menuItem('looper', 'A-B Precision Looper Deck', Icons.repeat_rounded),
              _menuItem('dj', 'DJ Mixing Console', Icons.album_rounded),
              _menuItem('dj_pro', 'DJ Pro Studio (8 Pads & FX)', Icons.speaker_group_rounded),
              _menuItem('karaoke', 'Karaoke Fullscreen HUD', Icons.mic_external_on_rounded),
              _menuItem('intelligence', 'Offline Music AI', Icons.psychology_rounded),
              _menuItem('duplicates', 'Duplicate Detective', Icons.cleaning_services_rounded),
              _menuItem('guide', 'Studio Guide & Feedback', Icons.menu_book_rounded),
              _menuItem('stats', 'Listening Analytics', Icons.analytics_rounded),
              _menuItem('backup', 'Offline Backup & Restore', Icons.security_rounded),
              _menuItem('settings', 'OS Settings', Icons.settings_rounded),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Category Switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SkeuoRockerSwitch<String>(
                  options: const [
                    RockerOption(value: 'SONGS', label: 'Songs', icon: Icons.music_note_rounded),
                    RockerOption(value: 'ALBUMS', label: 'Albums', icon: Icons.album_rounded),
                    RockerOption(value: 'ARTISTS', label: 'Artists', icon: Icons.person_rounded),
                    RockerOption(value: 'FAVORITES', label: 'Favorites', icon: Icons.favorite_rounded),
                    RockerOption(value: 'PLAYLISTS', label: 'Playlists', icon: Icons.queue_music_rounded),
                  ],
                  selectedValue: _activeTab,
                  activeColor: AppColors.kappogyYellow,
                  onSelected: (tab) => setState(() => _activeTab = tab),
                ),
              ),
            ),

            // Tab Content
            Expanded(
              child: libraryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.kappogyRed)),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.kappogyRed))),
                data: (tracks) {
                  if (_activeTab == 'SONGS') {
                    return _buildSongsList(tracks, playbackNotifier);
                  } else if (_activeTab == 'ALBUMS') {
                    return _buildAlbumsGrid(albums, playbackNotifier);
                  } else if (_activeTab == 'ARTISTS') {
                    return _buildArtistsList(artists, playbackNotifier);
                  } else if (_activeTab == 'FAVORITES') {
                    return _buildSongsList(favorites, playbackNotifier);
                  } else {
                    return _buildPlaylistsTab(playlistsAsync.value ?? [], playbackNotifier);
                  }
                },
              ),
            ),

            // Bottom Mini Player Dock
            MiniPlayerDock(onTap: _openNowPlaying),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsList(List<Track> tracks, PlaybackNotifier playbackNotifier) {
    if (tracks.isEmpty) {
      return const Center(
        child: Text(
          'No songs found. Scan a folder using the top right button.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      itemCount: tracks.length,
      itemBuilder: (context, idx) {
        final track = tracks[idx];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.panelRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            boxShadow: SkeuoTokens.raisedSm,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.panelSunken,
                boxShadow: SkeuoTokens.sunkenWell,
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
              ),
              child: const Center(
                child: Text(
                  'Ω',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.kappogyYellow),
                ),
              ),
            ),
            title: Text(
              track.title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    '${track.artist} • ${track.album}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.panelWell,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    track.codec,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.ledCyan),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    track.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: track.isFavorite ? AppColors.kappogyRed : AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () {
                    ref.read(libraryNotifierProvider.notifier).toggleFavorite(track.id);
                  },
                ),
                SkeuoButton(
                  size: 34,
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    playbackNotifier.playTrack(track, tracks);
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textMuted),
                  color: AppColors.chassisBg,
                  onSelected: (val) {
                    if (val == 'deck_a') {
                      ref.read(djConsoleNotifierProvider.notifier).loadTrackToDeck('DECK A', track);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Loaded "${track.title}" to DECK A'), backgroundColor: AppColors.ledCyan),
                      );
                    } else if (val == 'deck_b') {
                      ref.read(djConsoleNotifierProvider.notifier).loadTrackToDeck('DECK B', track);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Loaded "${track.title}" to DECK B'), backgroundColor: AppColors.kappogyRed),
                      );
                    } else if (val == 'spectral') {
                      SpectralAnalyzerDialog.show(context, track);
                    } else if (val == 'ringtone') {
                      RingtoneTrimmerDialog.show(context, track);
                    } else if (val == 'looper') {
                      playbackNotifier.playTrack(track, tracks);
                      AbLooperSheet.show(context);
                    } else if (val == 'tags') {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => TagEditorSheet(track: track),
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'deck_a', child: Text('Load to DJ Deck A')),
                    const PopupMenuItem(value: 'deck_b', child: Text('Load to DJ Deck B')),
                    const PopupMenuItem(value: 'spectral', child: Text('Inspect True Lossless (FFT)')),
                    const PopupMenuItem(value: 'looper', child: Text('A-B Practice Looper')),
                    const PopupMenuItem(value: 'ringtone', child: Text('Trim Ringtone / Alarm Tone')),
                    const PopupMenuItem(value: 'tags', child: Text('Edit ID3 Tags')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumsGrid(List<Album> albums, PlaybackNotifier playbackNotifier) {
    if (albums.isEmpty) return const Center(child: Text('No albums found', style: TextStyle(color: AppColors.textMuted)));

    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: albums.length,
      itemBuilder: (context, idx) {
        final album = albums[idx];
        return SkeuoPanel(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.panelSunken,
                      boxShadow: SkeuoTokens.sunkenWell,
                    ),
                    child: const Center(
                      child: Text('Ω', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.kappogyYellow)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(album.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary), maxLines: 1),
              Text('${album.artist} • ${album.trackCount} tracks', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: SkeuoButton(
                  size: 30,
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    if (album.tracks.isNotEmpty) {
                      playbackNotifier.playTrack(album.tracks.first, album.tracks);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArtistsList(List<Artist> artists, PlaybackNotifier playbackNotifier) {
    if (artists.isEmpty) return const Center(child: Text('No artists found', style: TextStyle(color: AppColors.textMuted)));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: artists.length,
      itemBuilder: (context, idx) {
        final artist = artists[idx];
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
                child: Icon(Icons.person_rounded, color: AppColors.ledCyan, size: 20),
              ),
            ),
            title: Text(artist.name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            subtitle: Text('${artist.albumCount} albums • ${artist.trackCount} songs', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            trailing: SkeuoButton(
              size: 34,
              icon: Icons.play_arrow_rounded,
              onPressed: () {
                if (artist.tracks.isNotEmpty) {
                  playbackNotifier.playTrack(artist.tracks.first, artist.tracks);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaylistsTab(List dynamicPlaylists, PlaybackNotifier playbackNotifier) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      children: [
        // Create Playlist Action
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.panelRaised,
              side: const BorderSide(color: AppColors.borderProminent, width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_rounded, color: AppColors.kappogyGreen),
            label: const Text('CREATE NEW LOCAL PLAYLIST', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            onPressed: () => _showCreatePlaylistDialog(context),
          ),
        ),
        const SizedBox(height: 12),

        ...dynamicPlaylists.map((pl) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.panelRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
              boxShadow: SkeuoTokens.raisedSm,
            ),
            child: ListTile(
              leading: const Icon(Icons.queue_music_rounded, color: AppColors.kappogyYellow),
              title: Text(pl.title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              subtitle: Text('${pl.trackCount} songs', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              trailing: SkeuoButton(
                size: 34,
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  if (pl.tracks.isNotEmpty) {
                    playbackNotifier.playTrack(pl.tracks.first, pl.tracks);
                  }
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.chassisBg,
        title: const Text('NEW PLAYLIST', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Enter playlist title...', hintStyle: TextStyle(color: AppColors.textMuted)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.kappogyGreen),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                ref.read(playlistsNotifierProvider.notifier).createPlaylist(ctrl.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, String text, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.ledCyan),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
