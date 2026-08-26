import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/audio_player/domain/track_model.dart';
import 'package:kappogy_music_os_pro/features/audio_player/data/spectral_analyzer_service.dart';

void main() {
  group('SpectralAnalyzerService Tests', () {
    test('FLAC / 24-bit studio master is verified as genuine lossless past 20kHz', () {
      final flacTrack = Track(
        id: 'test-flac-1',
        title: 'Master Afrobeats',
        artist: 'Kappogy Ohms',
        album: 'Studio Vault',
        durationMs: 180000,
        uri: '/storage/master.flac',
        codec: 'FLAC',
        bitrate: 1411,
        sampleRate: 48000,
        bitDepth: 24,
        dateAdded: 1700000000,
        folder: '/storage',
        fileSize: 45000000,
      );

      final result = SpectralAnalyzerService.analyzeTrack(flacTrack);

      expect(result.isGenuine, isTrue);
      expect(result.frequencyCutoffKhz, greaterThanOrEqualTo(21.0));
      expect(result.status, equals(SpectralVerificationStatus.trueLosslessMaster));
      expect(result.spectrumFftBins.length, equals(32));
    });

    test('128kbps low bitrate track triggers 16kHz low-pass transcode shelf warning', () {
      final mp3Track = Track(
        id: 'test-mp3-128',
        title: 'Compressed Demo',
        artist: 'Unknown',
        album: 'Web Rip',
        durationMs: 120000,
        uri: '/storage/rip.mp3',
        codec: 'MP3',
        bitrate: 128,
        sampleRate: 44100,
        bitDepth: 16,
        dateAdded: 1700000000,
        folder: '/storage',
        fileSize: 2500000,
      );

      final result = SpectralAnalyzerService.analyzeTrack(mp3Track);

      expect(result.isGenuine, isFalse);
      expect(result.frequencyCutoffKhz, lessThanOrEqualTo(16.5));
      expect(result.status, equals(SpectralVerificationStatus.lossyTranscodeShelf16k));
    });
  });
}
