import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/audio_player/domain/track_model.dart';
import 'package:kappogy_music_os_pro/features/library/data/duplicate_detective_service.dart';

void main() {
  group('DuplicateDetectiveService Tests', () {
    const trackA1 = Track(
      id: '1',
      uri: '/music/lagos_128k.mp3',
      title: 'Midnight Lagos',
      artist: 'Kappogy All-Stars',
      album: 'Studio Vault',
      durationMs: 214000,
      bitrate: 128,
      codec: 'MP3',
      fileSize: 3400000,
      folder: '/music',
      dateAdded: 1600000000,
    );

    const trackA2 = Track(
      id: '2',
      uri: '/music/lagos_master.flac',
      title: 'Midnight Lagos',
      artist: 'Kappogy All-Stars',
      album: 'Studio Vault Master',
      durationMs: 214000,
      bitrate: 1411,
      codec: 'FLAC',
      fileSize: 38000000,
      folder: '/music',
      dateAdded: 1600000000,
    );

    const trackB = Track(
      id: '3',
      uri: '/music/cybernetic.mp3',
      title: 'Cybernetic Pulse',
      artist: 'Neon Wave',
      album: 'Analog Dreams',
      durationMs: 185000,
      bitrate: 320,
      codec: 'MP3',
      fileSize: 7400000,
      folder: '/music',
      dateAdded: 1600000000,
    );

    test('finds duplicate sets by normalized artist and title', () {
      final duplicates = DuplicateDetectiveService.instance.findDuplicates([
        trackA1,
        trackA2,
        trackB,
      ]);

      expect(duplicates.length, 1);
      expect(duplicates.first.tracks.length, 2);
      expect(duplicates.first.bestQualityTrack.id, '2'); // FLAC 1411kbps
      expect(duplicates.first.redundantTracks.length, 1);
      expect(duplicates.first.redundantTracks.first.id, '1'); // MP3 128kbps
    });

    test('returns empty when no duplicates exist', () {
      final duplicates = DuplicateDetectiveService.instance.findDuplicates([
        trackA1,
        trackB,
      ]);

      expect(duplicates.isEmpty, true);
    });
  });
}
