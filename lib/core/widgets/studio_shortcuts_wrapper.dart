import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/audio_player/presentation/audio_providers.dart';

class StudioShortcutsWrapper extends ConsumerWidget {
  final Widget child;

  const StudioShortcutsWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(playbackStateProvider.notifier);
    final state = ref.watch(playbackStateProvider);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // Space -> Toggle Play / Pause
        const SingleActivator(LogicalKeyboardKey.space): () {
          notifier.togglePlayPause();
        },
        // Right Arrow -> Seek Forward 5 Seconds
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          final newPos = state.position + const Duration(seconds: 5);
          notifier.seek(newPos < state.duration ? newPos : state.duration);
        },
        // Left Arrow -> Seek Backward 5 Seconds
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          final newPos = state.position - const Duration(seconds: 5);
          notifier.seek(newPos > Duration.zero ? newPos : Duration.zero);
        },
        // Up Arrow -> Volume Up 5%
        const SingleActivator(LogicalKeyboardKey.arrowUp): () {
          final newVol = (state.volume + 0.05).clamp(0.0, 1.0);
          notifier.setVolume(newVol);
        },
        // Down Arrow -> Volume Down 5%
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          final newVol = (state.volume - 0.05).clamp(0.0, 1.0);
          notifier.setVolume(newVol);
        },
        // Key N or J -> Next Track
        const SingleActivator(LogicalKeyboardKey.keyN): () {
          notifier.next();
        },
        // Key P or K -> Previous Track
        const SingleActivator(LogicalKeyboardKey.keyP): () {
          notifier.previous();
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
