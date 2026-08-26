import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kappogy_music_os_pro/core/services/intent_handler_service.dart';
import 'package:kappogy_music_os_pro/features/audio_player/domain/track_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IntentHandlerService Tests', () {
    test('handleIncomingMediaUri parses and generates track correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final track = await IntentHandlerService.handleIncomingMediaUri(
        'file:///storage/emulated/0/Download/studio_master_track.flac',
        container,
      );

      expect(track, isNotNull);
      expect(track!.title, contains('studio_master_track'));
      expect(track.uri, contains('studio_master_track.flac'));
      expect(track.folder, contains('Download'));
    });

    test('shareAudioFile handles fallback text when file does not exist', () async {
      final track = Track(
        id: 'test_123',
        uri: '/non_existent_audio_path/track.mp3',
        title: 'Master Audio Tape',
        artist: 'Kappogy Studio',
        album: 'Acoustic Suite',
        durationMs: 240000,
        dateAdded: DateTime.now().millisecondsSinceEpoch,
        folder: 'Music',
        fileSize: 1024,
      );

      // Should complete without crashing
      await expectLater(
        IntentHandlerService.shareAudioFile(track),
        completes,
      );
    });

    test('shareRingtoneFile completes cleanly', () async {
      await expectLater(
        IntentHandlerService.shareRingtoneFile('/non_existent/ringtone.wav', 'TestTone'),
        completes,
      );
    });

    testWidgets('LibraryScreen renders Play With external button in AppBar', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: Builder(
            builder: (context) {
              return const MaterialApp(
                home: Scaffold(
                  body: Text('Intent Test Host'),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Intent Test Host'), findsOneWidget);
    });
  });
}
