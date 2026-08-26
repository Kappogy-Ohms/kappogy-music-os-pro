import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/audio_player/domain/track_model.dart';
import 'package:kappogy_music_os_pro/features/library/data/playlist_exporter.dart';
import 'package:kappogy_music_os_pro/features/library/domain/playlist_model.dart';

void main() {
  group('PlaylistExporter Tests', () {
    const playlist = Playlist(
      id: 'pl_1',
      title: 'Studio Master Hits',
      description: 'Lossless studio sessions',
      dateCreated: 1600000000,
    );

    const track1 = Track(
      id: 't1',
      uri: '/music/lagos.flac',
      title: 'Midnight Lagos',
      artist: 'Kappogy All-Stars',
      album: 'Studio Vault',
      durationMs: 214000,
      fileSize: 35000000,
      folder: '/music',
      dateAdded: 1600000000,
    );

    const track2 = Track(
      id: 't2',
      uri: '/music/golden.mp3',
      title: 'Golden Horizon',
      artist: 'Soul Strings',
      album: 'Golden',
      durationMs: 198000,
      fileSize: 7800000,
      folder: '/music',
      dateAdded: 1600000000,
    );

    test('exports playlist to valid M3U8 string with EXTINF headers', () {
      final m3u8 = PlaylistExporter.exportToM3u8(
        playlist: playlist,
        tracks: [track1, track2],
      );

      expect(m3u8.contains('#EXTM3U'), true);
      expect(m3u8.contains('#PLAYLIST:Studio Master Hits'), true);
      expect(m3u8.contains('#EXTINF:214,Kappogy All-Stars - Midnight Lagos'), true);
      expect(m3u8.contains('/music/lagos.flac'), true);
      expect(m3u8.contains('#EXTINF:198,Soul Strings - Golden Horizon'), true);
      expect(m3u8.contains('/music/golden.mp3'), true);
    });

    test('parses M3U file paths cleanly ignoring headers', () {
      const sampleM3u = '''
#EXTM3U
#PLAYLIST:Car Stereo
#EXTINF:214,Kappogy All-Stars - Midnight Lagos
/music/lagos.flac
#EXTINF:198,Soul Strings - Golden Horizon
/music/golden.mp3
''';

      final paths = PlaylistExporter.parseM3uPaths(sampleM3u);
      expect(paths.length, 2);
      expect(paths[0], '/music/lagos.flac');
      expect(paths[1], '/music/golden.mp3');
    });
  });
}
