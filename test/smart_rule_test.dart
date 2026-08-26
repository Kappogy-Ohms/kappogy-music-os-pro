import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/audio_player/domain/track_model.dart';
import 'package:kappogy_music_os_pro/features/intelligence/domain/smart_playlist_rule.dart';

void main() {
  group('SmartPlaylistRule Tests', () {
    const track1 = Track(
      id: '1',
      uri: '/test/afro.mp3',
      title: 'Afro Beat Master',
      artist: 'Kappogy Star',
      album: 'Lagos Sunset',
      genre: 'Afrobeats',
      durationMs: 210000,
      fileSize: 5000000,
      codec: 'MP3',
      bitrate: 320,
      sampleRate: 44100,
      bpm: 122.0,
      musicalKey: 'Am',
      rating: 5,
      isFavorite: true,
      playCount: 15,
      dateAdded: 1700000000000,
      folder: '/test',
    );

    const track2 = Track(
      id: '2',
      uri: '/test/chill.mp3',
      title: 'Midnight Chill',
      artist: 'LoFi Beats',
      album: 'Night Coffee',
      genre: 'Lo-Fi',
      durationMs: 180000,
      fileSize: 4000000,
      codec: 'MP3',
      bitrate: 320,
      sampleRate: 44100,
      bpm: 82.0,
      musicalKey: 'C',
      rating: 3,
      isFavorite: false,
      playCount: 2,
      dateAdded: 1700000000000,
      folder: '/test',
    );

    test('filters high energy tracks correctly', () {
      final highEnergyRule = SmartPlaylistRule.highEnergy();
      expect(highEnergyRule.matches(track1), true);
      expect(highEnergyRule.matches(track2), false);
    });

    test('filters favorite 5-star tracks correctly', () {
      final hallOfFameRule = SmartPlaylistRule.hallOfFame();
      expect(hallOfFameRule.matches(track1), true);
      expect(hallOfFameRule.matches(track2), false);
    });
  });
}
