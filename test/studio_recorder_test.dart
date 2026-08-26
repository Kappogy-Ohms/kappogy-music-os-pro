import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kappogy_music_os_pro/features/recorder/domain/studio_recording_model.dart';
import 'package:kappogy_music_os_pro/features/recorder/presentation/studio_recorder_providers.dart';
import 'package:kappogy_music_os_pro/features/recorder/presentation/studio_recorder_sheet.dart';

void main() {
  group('StudioRecorder Tests', () {
    test('StudioRecorderNotifier starts, sets gain, and stops take cleanly', () {
      final notifier = StudioRecorderNotifier();
      addTearDown(notifier.dispose);

      expect(notifier.state.isRecording, isFalse);
      expect(notifier.state.preampGain, equals(6.0));

      notifier.setPreampGain(12.5);
      expect(notifier.state.preampGain, equals(12.5));

      notifier.toggleOverdub();
      expect(notifier.state.overdubEnabled, isTrue);

      notifier.setFormat(RecordingFormat.broadcastWav);
      expect(notifier.state.format, equals(RecordingFormat.broadcastWav));

      notifier.startRecording(backingTrackTitle: 'Reference Vocal Track');
      expect(notifier.state.isRecording, isTrue);

      final take = notifier.stopAndSaveRecording(title: 'Lead Vocal Take 1');
      expect(take, isNotNull);
      expect(take!.title, equals('Lead Vocal Take 1'));
      expect(take.isOverdub, isTrue);
      expect(take.format, equals(RecordingFormat.broadcastWav));
      expect(notifier.state.isRecording, isFalse);
      expect(notifier.state.recordings.length, equals(1));
    });

    testWidgets('StudioRecorderSheet renders dual VU gauges and transport button', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StudioRecorderSheet(),
            ),
          ),
        ),
      );

      expect(find.text('STUDIO 24-BIT RECORDER & OVERDUB LAB'), findsOneWidget);
      expect(find.text('LIVE ANALOG PREAMP VU METERS'), findsOneWidget);
      expect(find.text('L - CHANNEL'), findsOneWidget);
      expect(find.text('R - CHANNEL'), findsOneWidget);
      expect(find.text('START RECORDING'), findsOneWidget);
    });
  });
}
