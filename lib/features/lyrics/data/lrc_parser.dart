import 'dart:io';
import '../domain/lrc_lyrics.dart';

class LrcParser {
  static LrcLyrics parseString(String lrcContent) {
    final List<LyricsLine> lines = [];
    String title = '';
    String artist = '';

    final rawLines = lrcContent.split('\n');
    final tagRegex = RegExp(r'\[(\d{2}):(\d{2})\.?(\d{2,3})?\]');

    for (final raw in rawLines) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('[ti:')) {
        title = line.replaceFirst('[ti:', '').replaceAll(']', '').trim();
      } else if (line.startsWith('[ar:')) {
        artist = line.replaceFirst('[ar:', '').replaceAll(']', '').trim();
      } else {
        final matches = tagRegex.allMatches(line);
        if (matches.isNotEmpty) {
          final match = matches.first;
          final min = int.parse(match.group(1)!);
          final sec = int.parse(match.group(2)!);
          final msStr = match.group(3) ?? '0';
          final ms = int.parse(msStr.padRight(3, '0').substring(0, 3));

          final duration = Duration(minutes: min, seconds: sec, milliseconds: ms);
          final text = line.replaceAll(tagRegex, '').trim();

          if (text.isNotEmpty) {
            lines.add(LyricsLine(timestamp: duration, text: text));
          }
        }
      }
    }

    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return LrcLyrics(title: title, artist: artist, lines: lines);
  }

  static Future<LrcLyrics?> parseFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    return parseString(content);
  }

  static LrcLyrics generateSampleLyrics(String trackTitle, String artist) {
    return LrcLyrics(
      title: trackTitle,
      artist: artist,
      lines: [
        const LyricsLine(timestamp: Duration(seconds: 2), text: "♪ [Studio Intro Riff] ♪"),
        LyricsLine(timestamp: const Duration(seconds: 8), text: "Feel the pulse inside the rhythm, $artist"),
        const LyricsLine(timestamp: Duration(seconds: 16), text: "Kappogy sound system operating offline"),
        const LyricsLine(timestamp: Duration(seconds: 24), text: "Analog frequencies warm and deep"),
        const LyricsLine(timestamp: Duration(seconds: 32), text: "Precision equalized across every frequency"),
        const LyricsLine(timestamp: Duration(seconds: 42), text: "♪ [Bass drop and groove chorus] ♪"),
        LyricsLine(timestamp: const Duration(seconds: 52), text: "This is $trackTitle playing in high resolution"),
        const LyricsLine(timestamp: Duration(seconds: 64), text: "Pure offline music intelligence"),
        const LyricsLine(timestamp: Duration(seconds: 78), text: "Locked into the master groove"),
      ],
    );
  }
}
