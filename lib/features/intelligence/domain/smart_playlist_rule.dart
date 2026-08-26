import '../../audio_player/domain/track_model.dart';

class SmartPlaylistRule {
  final String field; // 'bpm', 'rating', 'genre', 'play_count', 'is_favorite'
  final String operator; // '>', '<', '=', '>=', '<=', 'contains'
  final dynamic value;

  const SmartPlaylistRule({
    required this.field,
    required this.operator,
    required this.value,
  });

  factory SmartPlaylistRule.highEnergy() => const SmartPlaylistRule(
        field: 'bpm',
        operator: '>=',
        value: 120.0,
      );

  factory SmartPlaylistRule.hallOfFame() => const SmartPlaylistRule(
        field: 'rating',
        operator: '>=',
        value: 4.5,
      );

  bool matches(Track track) {
    if (field == 'bpm') {
      final double val = (value as num).toDouble();
      if (operator == '>=') return track.bpm >= val;
      if (operator == '<=') return track.bpm <= val;
      if (operator == '>') return track.bpm > val;
      if (operator == '<') return track.bpm < val;
    } else if (field == 'rating') {
      final double val = (value as num).toDouble();
      if (operator == '>=') return track.rating >= val;
      if (operator == '<=') return track.rating <= val;
      if (operator == '>') return track.rating > val;
      if (operator == '<') return track.rating < val;
    } else if (field == 'genre') {
      final String val = value.toString().toLowerCase();
      return track.genre.toLowerCase().contains(val);
    } else if (field == 'is_favorite') {
      return track.isFavorite == (value as bool);
    }
    return true;
  }
}
