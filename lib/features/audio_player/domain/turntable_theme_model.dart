import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DeckVisualizerTheme {
  classicStudio('Classic Studio Vinyl', Icons.album_rounded, '33 RPM Matte Black with Omega Center'),
  technics1200('Technics 1200 DJ Strobe', Icons.speed_rounded, 'Direct-Drive Strobe Dots & Quartz Red Laser'),
  reelToReel('Studio 10.5" Reel-to-Reel', Icons.radio_rounded, 'Studer/Akai Dual Aluminum 3-Hole Spools'),
  clearaudioAcrylic('Audiophile Clear Acrylic', Icons.diamond_rounded, 'Translucent Acrylic & 24k Gold Spindle'),
  neonCyber('UV Cyber Fluorescent', Icons.flare_rounded, 'Glowing Neon Cyan & Magenta Vinyl Grooves');

  final String label;
  final IconData icon;
  final String description;
  const DeckVisualizerTheme(this.label, this.icon, this.description);
}

class DeckVisualizerThemeNotifier extends StateNotifier<DeckVisualizerTheme> {
  DeckVisualizerThemeNotifier() : super(DeckVisualizerTheme.classicStudio);

  void setTheme(DeckVisualizerTheme theme) {
    state = theme;
  }
}

final deckVisualizerThemeProvider = StateNotifierProvider<DeckVisualizerThemeNotifier, DeckVisualizerTheme>((ref) {
  return DeckVisualizerThemeNotifier();
});
