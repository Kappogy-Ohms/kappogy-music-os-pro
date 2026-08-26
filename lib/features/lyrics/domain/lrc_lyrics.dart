class LyricsLine {
  final Duration timestamp;
  final String text;

  const LyricsLine({
    required this.timestamp,
    required this.text,
  });
}

class LrcLyrics {
  final String title;
  final String artist;
  final List<LyricsLine> lines;

  const LrcLyrics({
    this.title = '',
    this.artist = '',
    this.lines = const [],
  });

  int getActiveLineIndex(Duration currentPosition) {
    if (lines.isEmpty) return -1;
    for (int i = lines.length - 1; i >= 0; i--) {
      if (currentPosition >= lines[i].timestamp) {
        return i;
      }
    }
    return 0;
  }
}
