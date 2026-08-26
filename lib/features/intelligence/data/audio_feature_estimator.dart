import '../../audio_player/domain/track_model.dart';

class AudioFeatureEstimator {
  /// Estimates mood, energy, and musical characteristics based on tempo, key, and metadata
  static Track analyzeTrack(Track track) {
    double energy = 0.5;
    String mood = 'Neutral';

    final bpm = track.bpm;
    final genre = track.genre.toLowerCase();

    if (genre.contains('afrobeats') || genre.contains('dance') || genre.contains('club')) {
      energy = 0.85;
      mood = 'Groovy & Upbeat';
    } else if (genre.contains('hip-hop') || genre.contains('rap')) {
      energy = 0.70;
      mood = 'Focused & Heavy';
    } else if (genre.contains('gospel') || genre.contains('soul')) {
      energy = 0.60;
      mood = 'Uplifting & Soulful';
    } else if (genre.contains('rock') || genre.contains('metal')) {
      energy = 0.90;
      mood = 'Aggressive & Dynamic';
    } else if (genre.contains('ambient') || genre.contains('acoustic') || genre.contains('chill')) {
      energy = 0.35;
      mood = 'Peaceful & Relaxed';
    }

    if (bpm > 125) {
      energy = (energy + 0.15).clamp(0.1, 1.0);
    } else if (bpm < 90) {
      energy = (energy - 0.15).clamp(0.1, 1.0);
    }

    return track.copyWith(energy: energy, mood: mood);
  }

  /// Generates smart playlists from local library
  static Map<String, List<Track>> generateSmartPlaylists(List<Track> library) {
    return {
      '⚡ High Energy (Workout)': library.where((t) => t.energy >= 0.8 || t.bpm >= 120).toList(),
      '🌙 Chill & Relaxed': library.where((t) => t.energy < 0.6 || t.bpm < 100).toList(),
      '🔥 Most Played Studio Mix': library.where((t) => t.playCount >= 5).toList(),
      '⭐ 5-Star Hall of Fame': library.where((t) => t.rating == 5 || t.isFavorite).toList(),
      '🥁 Afrobeats & Club': library.where((t) => t.genre.toLowerCase().contains('afro') || t.genre.toLowerCase().contains('club')).toList(),
    };
  }
}
