import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/lyrics/data/lrc_parser.dart';

void main() {
  group('LrcParser Tests', () {
    test('parses timestamped LRC strings', () {
      const lrcData = '''
[ti:Test Song]
[ar:Kappogy Artist]
[00:04.50]First line of vocals
[00:10.20]Second line of chorus
[01:05.00]Bridge section
''';

      final result = LrcParser.parseString(lrcData);
      expect(result.title, 'Test Song');
      expect(result.artist, 'Kappogy Artist');
      expect(result.lines.length, 3);

      expect(result.lines[0].text, 'First line of vocals');
      expect(result.lines[0].timestamp, const Duration(seconds: 4, milliseconds: 500));

      expect(result.lines[1].text, 'Second line of chorus');
      expect(result.lines[1].timestamp, const Duration(seconds: 10, milliseconds: 200));

      expect(result.lines[2].text, 'Bridge section');
      expect(result.lines[2].timestamp, const Duration(minutes: 1, seconds: 5));
    });

    test('retrieves active line index based on playback position', () {
      final lyrics = LrcParser.generateSampleLyrics('Studio Track', 'Artist');
      final active0 = lyrics.getActiveLineIndex(const Duration(seconds: 10));
      expect(active0, 1);

      final active2 = lyrics.getActiveLineIndex(const Duration(seconds: 28));
      expect(active2, 3);
    });
  });
}
