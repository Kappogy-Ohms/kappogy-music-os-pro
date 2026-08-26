import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../audio_player/presentation/audio_providers.dart';
import '../data/lrc_parser.dart';
import '../domain/lrc_lyrics.dart';
import 'karaoke_hud_screen.dart';
import 'vocal_remover_sheet.dart';

class LyricsScreen extends ConsumerStatefulWidget {
  const LyricsScreen({super.key});

  @override
  ConsumerState<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends ConsumerState<LyricsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _offsetMs = 0;
  LrcLyrics? _lyrics;
  int _lastActiveIdx = -1;

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackStateProvider);
    final notifier = ref.read(playbackStateProvider.notifier);
    final track = playbackState.currentTrack;

    if (_lyrics == null && track != null) {
      _lyrics = LrcParser.generateSampleLyrics(track.title, track.artist);
    }

    final adjustedPos = playbackState.position + Duration(milliseconds: _offsetMs);
    final activeIdx = _lyrics?.getActiveLineIndex(adjustedPos) ?? -1;

    // Auto-scroll when active line changes
    if (activeIdx != _lastActiveIdx && activeIdx >= 0 && _scrollController.hasClients) {
      _lastActiveIdx = activeIdx;
      _scrollController.animateTo(
        activeIdx * 64.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

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
        title: Text(
          track?.title.toUpperCase() ?? 'LYRICS',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
            shadows: SkeuoTokens.debossedText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: SkeuoButton(
              size: 40,
              icon: Icons.mic_off_rounded,
              tooltip: 'Vocal Remover & Stem Extractor',
              activeColor: AppColors.ledPurple,
              onPressed: () => VocalRemoverSheet.show(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: SkeuoButton(
              size: 40,
              icon: Icons.fullscreen_rounded,
              tooltip: 'Karaoke Fullscreen HUD',
              activeColor: AppColors.kappogyYellow,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const KaraokeHudScreen()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SkeuoButton(
              size: 40,
              icon: Icons.edit_note_rounded,
              tooltip: 'Edit Lyrics',
              onPressed: () => _showLyricsEditor(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timing Sync Fine-Tuning Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: SkeuoPanel(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SYNC OFFSET',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Row(
                      children: [
                        SkeuoButton(
                          size: 32,
                          isCircular: false,
                          icon: Icons.remove,
                          onPressed: () {
                            setState(() => _offsetMs -= 500);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            '${_offsetMs >= 0 ? "+" : ""}${(_offsetMs / 1000).toStringAsFixed(1)}s',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ledCyan,
                            ),
                          ),
                        ),
                        SkeuoButton(
                          size: 32,
                          isCircular: false,
                          icon: Icons.add,
                          onPressed: () {
                            setState(() => _offsetMs += 500);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Karaoke Scrolling Lyrics View
            Expanded(
              child: _lyrics == null || _lyrics!.lines.isEmpty
                  ? const Center(
                      child: Text(
                        'No lyrics found for this track',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                      itemCount: _lyrics!.lines.length,
                      itemBuilder: (context, idx) {
                        final line = _lyrics!.lines[idx];
                        final isActive = idx == activeIdx;

                        return GestureDetector(
                          onTap: () {
                            notifier.seek(line.timestamp);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.panelRaised : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive ? AppColors.ledCyan.withValues(alpha: 0.4) : Colors.transparent,
                                width: 1.0,
                              ),
                              boxShadow: isActive
                                  ? [
                                      ...SkeuoTokens.raisedSm,
                                      BoxShadow(
                                        color: AppColors.ledCyan.withValues(alpha: 0.15),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              line.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isActive ? 19.0 : 15.0,
                                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                                color: isActive ? AppColors.textPrimary : AppColors.textMuted,
                                shadows: isActive
                                    ? [
                                        Shadow(
                                          color: AppColors.ledCyan.withValues(alpha: 0.7),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                                height: 1.4,
                              ),
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

  void _showLyricsEditor(BuildContext context) {
    final textController = TextEditingController(
      text: _lyrics?.lines.map((l) => "[${l.timestamp.inMinutes.toString().padLeft(2, '0')}:${(l.timestamp.inSeconds % 60).toString().padLeft(2, '0')}.00] ${l.text}").join("\n") ?? "",
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.chassisBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'OFFLINE LRC LYRICS EDITOR',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          content: SizedBox(
            width: 400,
            height: 300,
            child: TextField(
              controller: textController,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.panelWell,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.kappogyRed),
              onPressed: () {
                final parsed = LrcParser.parseString(textController.text);
                setState(() {
                  _lyrics = parsed;
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('SAVE LYRICS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
