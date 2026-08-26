import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/audio_player/presentation/sleep_timer_sheet.dart';

void main() {
  group('SleepTimerState Tests', () {
    test('default state is inactive', () {
      const state = SleepTimerState();
      expect(state.isActive, false);
      expect(state.remainingSeconds, 0);
      expect(state.endOfTrack, false);
      expect(state.fadeOut, true);
    });

    test('active state preserves remaining seconds and flags', () {
      const state = SleepTimerState(
        isActive: true,
        remainingSeconds: 1800,
        fadeOut: true,
      );
      expect(state.isActive, true);
      expect(state.remainingSeconds, 1800);
      expect(state.fadeOut, true);
    });
  });
}
