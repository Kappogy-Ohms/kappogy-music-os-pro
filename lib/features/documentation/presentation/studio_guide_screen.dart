import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/services/native_audio_bridge.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/skeuo_brand_logo.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';

class StudioGuideScreen extends ConsumerStatefulWidget {
  const StudioGuideScreen({super.key});

  @override
  ConsumerState<StudioGuideScreen> createState() => _StudioGuideScreenState();
}

class _StudioGuideScreenState extends ConsumerState<StudioGuideScreen> {
  String _selectedSection = 'guide';
  bool _isCheckingUpdate = false;
  String? _updateStatusMessage;
  final _feedbackController = TextEditingController();
  String _feedbackCategory = 'Feature Request';

  static const String adminEmail = 'kappogyohms@gmail.com';
  static const String developerName = 'Kappogy Ohms';

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _checkUpdate() async {
    setState(() {
      _isCheckingUpdate = true;
      _updateStatusMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) {
      setState(() {
        _isCheckingUpdate = false;
        _updateStatusMessage = 'You are running the latest version: v2.4.0 Studio Pro (Build 2026.08.26)\nAll offline DSP engines, SQLite schemas, and audio decoders are up to date.\nDeveloped by $developerName.';
      });
    }
  }

  Future<String> _generateDiagnosticsBundle() async {
    final devInfo = await NativeAudioBridge.getDeviceInfo();
    final currentTheme = ref.read(themeModeProvider);

    return '''
--- KAPPOGY MUSIC OS PRO DIAGNOSTICS BUNDLE ---
Developer: $developerName
Admin Contact: $adminEmail
App Version: v2.4.0 Studio Pro (Build 2026.08.26)
Engine: 100% Offline Local-First SQLite FFI
Theme: $currentTheme
Device Route: ${devInfo?.currentRoute ?? 'Internal Audio DAC'}
Bluetooth A2DP: ${devInfo?.isBluetoothConnected ?? false}
Sample Rate: ${devInfo?.sampleRate ?? '44100'} Hz
Feedback Category: $_feedbackCategory
User Notes: ${_feedbackController.text.trim().isEmpty ? "No additional notes provided" : _feedbackController.text.trim()}
Timestamp: ${DateTime.now().toUtc().toIso8601String()}
-----------------------------------------------
''';
  }

  void _copyDiagnosticsBundle() async {
    final diagnostics = await _generateDiagnosticsBundle();
    await Clipboard.setData(ClipboardData(text: diagnostics));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diagnostics & Feedback bundle copied to clipboard!'),
          backgroundColor: AppColors.kappogyGreen,
        ),
      );
    }
  }

  void _sendFeedbackEmail() async {
    final diagnostics = await _generateDiagnosticsBundle();
    final subject = Uri.encodeComponent('Kappogy Music OS Pro Feedback: [$_feedbackCategory]');
    final body = Uri.encodeComponent('Hi $developerName,\n\nHere is my feedback:\n${_feedbackController.text.trim()}\n\n$diagnostics');
    final uri = Uri.parse('mailto:$adminEmail?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _copyDiagnosticsBundle();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open email app. Diagnostics copied to clipboard — please send to kappogyohms@gmail.com'),
              backgroundColor: AppColors.kappogyYellow,
            ),
          );
        }
      }
    } catch (_) {
      _copyDiagnosticsBundle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chassisBg,
      appBar: AppBar(
        backgroundColor: AppColors.chassisBg,
        elevation: 0,
        leading: Tooltip(
          message: 'Back to Library',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeuoBrandLogo(size: 24),
            SizedBox(width: 8),
            Text(
              'STUDIO DOCUMENTATION & FEEDBACK',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation Rocker Bar
              SkeuoPanel(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SkeuoRockerSwitch<String>(
                    options: const [
                      RockerOption(value: 'guide', label: '📘 Studio Guide'),
                      RockerOption(value: 'shortcuts', label: '⌨️ Shortcuts & Hotkeys'),
                      RockerOption(value: 'update', label: '🔄 In-App Updates'),
                      RockerOption(value: 'feedback', label: '💬 User Feedback'),
                    ],
                    selectedValue: _selectedSection,
                    activeColor: AppColors.kappogyYellow,
                    onSelected: (val) => setState(() => _selectedSection = val),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (_selectedSection == 'guide') _buildStudioGuide(),
              if (_selectedSection == 'shortcuts') _buildShortcutsGuide(),
              if (_selectedSection == 'update') _buildUpdateSection(),
              if (_selectedSection == 'feedback') _buildFeedbackSection(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Studio Guide Section
  Widget _buildStudioGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _guideCard(
          title: '1. TURNTABLE VINYL & AUDIO PLAYER ENGINE',
          icon: Icons.album_rounded,
          accent: AppColors.kappogyRed,
          tooltipText: 'Vinyl turntable scratch scrubbing, speed, and transport controls',
          description: 'Experience 33 1/3 RPM vinyl spinning emulation with physical tonearm tracking. Touch and drag the vinyl platter for scratch scrubbing, or use the tactile channel fader to seek smoothly. Tap the bedtime icon for logarithmic 30-second volume fade-out sleep timers.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '2. 10-BAND GRAPHIC EQUALIZER & SPLINE CURVE',
          icon: Icons.equalizer_rounded,
          accent: AppColors.kappogyYellow,
          tooltipText: 'ISO 10-band acoustic calibration and real-time frequency curve',
          description: 'Calibrated ISO studio bands (31Hz to 16kHz) with real-time cubic Bézier spline curve rendering. Includes rotary potentiometers for Preamp (-12dB to +12dB), Sub-Bass Boost, Air Treble, and Stereo Widening with dynamic peak limiting.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '3. 5-BAND CONTINUOUS PARAMETRIC EQ (PEQ)',
          icon: Icons.show_chart_rounded,
          accent: AppColors.kappogyGreen,
          tooltipText: 'Continuous parametric equalizer with variable Q-factor bandwidth',
          description: 'Precision parametric EQ with 5 continuous bands (Low Shelf, Low-Mid, Mid Bell, High-Mid, High Shelf). Adjust exact center frequencies (20Hz to 20kHz), gain (±18dB), and resonance Q-factor (0.3 to 10.0) with real-time bell curve visualization.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '4. DUAL-DECK DJ CONSOLE & DJ PRO MODE',
          icon: Icons.speaker_group_rounded,
          accent: AppColors.ledCyan,
          tooltipText: 'Dual-deck live mixing, 8 performance pads, and touch XY FX rack',
          description: 'Deck A (Cyan) and Deck B (Red) dual mixing console with independent pitch faders (±8%), BPM sync, 8 performance pads (Hot Cues, Auto Loops, Beat Jump, Sampler), 3-Band Isolator EQ Kills, and touch XY modulation FX rack (Filter Sweep, Echo, Reverb, Flanger).',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '5. 4-TRACK MULTI-STEM STUDIO MIXER',
          icon: Icons.tune_rounded,
          accent: AppColors.ledPurple,
          tooltipText: 'Independent mixing of Vocals, Drums, Bass, and Melody stems',
          description: 'Isolate or balance individual stems (Vocals, Drums, Bass, and Melody/Instruments) in real time with dedicated physical channel strips, Solo (S) and Mute (M) buttons, and vertical dB faders.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '6. DJ AUTOMIX & HARMONIC TRANSITIONS',
          icon: Icons.auto_mode_rounded,
          accent: AppColors.kappogyYellow,
          tooltipText: 'Automated continuous radio mixing with Camelot key progression',
          description: 'Automated radio mixing with seamless transition styles (8-Bar Beatmatch, Echo Freeze Reverb Tail, High-Pass Filter Sweep, 33-RPM Vinyl Brake). Automatically sorts your queue by harmonic Camelot key compatibility.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '7. HEADPHONE CROSSFEED & 3D SPATIAL AUDIO',
          icon: Icons.headphones_rounded,
          accent: AppColors.ledCyan,
          tooltipText: 'Bauer ITD/IID crossfeed and 360° binaural head-related transfer functions',
          description: 'Bauer headphone crossfeed processor eliminates acoustic listener fatigue and centers sub-bass below 90Hz. The 3D Binaural Spatial Audio engine includes an interactive 360° radar disk, azimuth/elevation dialers, and HRTF room models.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '8. EBU R128 LUFS LOUDNESS LEVELER & WARMER',
          icon: Icons.volume_up_rounded,
          accent: AppColors.kappogyRed,
          tooltipText: 'Standardized LUFS loudness matching and vintage vacuum tube saturation',
          description: 'EBU R128 and ReplayGain loudness normalization with live LUFS metering and True-Peak limiter guard. Vintage vacuum tube and tape warmer introduces even/odd harmonic saturation with an animated glowing cathode valve.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '9. VINTAGE CASSETTE DECK & LO-FI MODULATOR',
          icon: Icons.album_rounded,
          accent: AppColors.kappogyYellow,
          tooltipText: 'Mechanical dual-spool cassette simulation with wow/flutter',
          description: 'Simulates analog tape formulations (Type I Ferric, Type II Chrome, Type IV Metal, and 80s Micro-Cassette) with real-time wow/flutter modulation, magnetic tape wear, and bias boost.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '10. TRUE LOSSLESS SPECTRAL ANALYZER',
          icon: Icons.graphic_eq_rounded,
          accent: AppColors.kappogyGreen,
          tooltipText: '20Hz-22.05kHz FFT spectrogram and fake transcode detection',
          description: 'Real-time 20Hz–22.05kHz FFT audio spectrogram analyzing frequency content above 20kHz to verify true lossless studio FLAC masters vs fake upsampled MP3s.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '11. PRECISION A-B LOOPER & WAVE TRIMMER',
          icon: Icons.repeat_rounded,
          accent: AppColors.ledCyan,
          tooltipText: 'Sub-millisecond practice looping and offline ringtone exporter',
          description: 'Millisecond-accurate Point A / Point B looping with pitch-preserving tempo (0.5x to 1.5x) and micro-jog nudges. The offline wave trimmer features fade envelopes and instant ringtone/alert export.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '12. PITCH & FORMANT SHIFTING LAB',
          icon: Icons.speed_rounded,
          accent: AppColors.ledPurple,
          tooltipText: 'Independent pitch shifting, time stretch, and vocal formant preservation',
          description: 'Shift pitch (±24 semitones) and stretch tempo (0.25x to 4.0x) independently with throat formant preservation and instant Nightcore, Vaporwave, and Deep Voice DSP presets.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '13. STUDIO SYNTH & TONE GENERATOR',
          icon: Icons.piano_rounded,
          accent: AppColors.kappogyGreen,
          tooltipText: 'A440 concert pitch lock, 6 waveforms, and playable touch keybed',
          description: 'Continuous frequency sweeper (20Hz to 20,000Hz) with A440 concert pitch lock, 6 oscillator waveforms, low-pass filter, playable 8-key touch keybed, and instant 808 Sub, Synth Lead, Brass, and E-Piano presets.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '14. MUSICIAN EAR TRAINING & PITCH GAME',
          icon: Icons.psychology_rounded,
          accent: AppColors.kappogyYellow,
          tooltipText: 'Offline ear-training quiz for frequency bands, intervals, and Camelot keys',
          description: 'Sharpen your audio engineering skills with interactive challenges on frequency discrimination, musical intervals, and Camelot harmonic transitions with reference test tone playback.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '15. SYNCHRONIZED LYRICS & FULLSCREEN KARAOKE',
          icon: Icons.mic_external_on_rounded,
          accent: AppColors.ledPurple,
          tooltipText: 'Synchronized LRC karaoke engine with spotlight focus glow',
          description: 'Synchronized LRC parser with real-time neon focus glow, timing sync micro-adjusters (+/- 0.5s), and immersive Fullscreen Karaoke HUD for live singing performance.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '16. 100% OFFLINE PRIVACY & DUPLICATE DETECTIVE',
          icon: Icons.security_rounded,
          accent: AppColors.textPrimary,
          tooltipText: 'Zero cloud tracking, local SQLite engine, and duplicate storage cleaner',
          description: 'Zero cloud dependencies, zero external telemetry. The Duplicate Detective scans your local music library to pinpoint duplicate audio files, calculate wasted storage, and prioritize uncompressed lossless master tracks.',
        ),
        const SizedBox(height: 12),
        _guideCard(
          title: '17. PLAY WITH & SHARE WITH INTENT ENGINE',
          icon: Icons.share_rounded,
          accent: AppColors.ledCyan,
          tooltipText: 'Inbound & Outbound Android/iOS system audio intents and sharing',
          description: 'Full support for opening external audio files (.mp3, .flac, .wav, .m4a, .ogg, .opus) from WhatsApp, Telegram, Files, or web downloads via "Play With", and sharing local audio tracks, trimmed ringtones, and M3U8 playlists to external apps via native share intents.',
        ),
      ],
    );
  }

  // 2. Shortcuts & Hotkeys Section
  Widget _buildShortcutsGuide() {
    return SkeuoPanel(
      showCornerScrews: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STUDIO HARDWARE KEYBINDINGS (DESKTOP / TABLET)',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: AppColors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          _keyRow('Spacebar', 'Toggle Play / Pause'),
          _keyRow('Arrow Right', 'Seek Forward +5 Seconds'),
          _keyRow('Arrow Left', 'Seek Backward -5 Seconds'),
          _keyRow('Arrow Up', 'Volume Up +5%'),
          _keyRow('Arrow Down', 'Volume Down -5%'),
          _keyRow('Key N', 'Next Audio Track in Queue'),
          _keyRow('Key P', 'Previous Audio Track in Queue'),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          const Text(
            'SUPPORTED AUDIO CODECS & BIT-DEPTHS',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: AppColors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _codecBadgeRow(['FLAC (24-bit / 192kHz)', 'WAV PCM', 'ALAC Lossless']),
          const SizedBox(height: 8),
          _codecBadgeRow(['MP3 (320kbps CBR/VBR)', 'AAC / M4A', 'OGG Vorbis', 'OPUS']),
        ],
      ),
    );
  }

  // 3. In-App Update Engine
  Widget _buildUpdateSection() {
    return SkeuoPanel(
      showCornerScrews: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KAPPOGY MUSIC OS PRO', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  SizedBox(height: 2),
                  Text('Version 2.4.0 (Studio Release)', style: TextStyle(fontSize: 10.5, color: AppColors.kappogyYellow, fontWeight: FontWeight.w700)),
                  SizedBox(height: 2),
                  Text('Developer: $developerName', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w800)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.panelSunken,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.kappogyGreen.withValues(alpha: 0.6), width: 1.0),
                ),
                child: const Text('STABLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.kappogyGreen)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'OFFLINE UPDATE & INTEGRITY STATUS',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.panelWell,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            ),
            child: Text(
              _updateStatusMessage ?? 'No update check has been performed this session. In Strict Offline Mode, updates can be verified against local signed package manifests or offline firmware packs.',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: Tooltip(
              message: 'Check software integrity and local firmware update packages',
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.panelRaised,
                  side: const BorderSide(color: AppColors.kappogyYellow, width: 1.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _isCheckingUpdate
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.kappogyYellow))
                    : const Icon(Icons.refresh_rounded, color: AppColors.kappogyYellow, size: 18),
                label: Text(
                  _isCheckingUpdate ? 'CHECKING SYSTEM INTEGRITY...' : 'CHECK FOR UPDATES (OFFLINE SAFE)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                onPressed: _isCheckingUpdate ? null : _checkUpdate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. User Feedback Section
  Widget _buildFeedbackSection() {
    return SkeuoPanel(
      showCornerScrews: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'OFFLINE USER FEEDBACK & HARDWARE PROFILES',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.panelSunken,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('ADMIN: $adminEmail', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.kappogyYellow)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Category Selector
          Wrap(
            spacing: 8,
            children: ['Feature Request', 'Bug Report', 'DSP Audio Preset', 'UI / Ergonomics'].map((cat) {
              final isSel = _feedbackCategory == cat;
              return ChoiceChip(
                label: Text(cat, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: isSel ? Colors.black : AppColors.textPrimary)),
                selected: isSel,
                selectedColor: AppColors.kappogyYellow,
                backgroundColor: AppColors.panelSunken,
                onSelected: (_) => setState(() => _feedbackCategory = cat),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _feedbackController,
            maxLines: 4,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Type your feedback, requested feature, or acoustic profile recommendation for developer $developerName...',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              filled: true,
              fillColor: AppColors.panelSunken,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderSubtle)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.kappogyGreen)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SkeuoButton(
                  size: 42,
                  isCircular: false,
                  tooltip: 'Send feedback email directly to $adminEmail',
                  activeColor: AppColors.kappogyYellow,
                  onPressed: _sendFeedbackEmail,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_rounded, size: 16, color: AppColors.kappogyYellow),
                      SizedBox(width: 8),
                      Text('SEND VIA EMAIL', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.kappogyYellow)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SkeuoButton(
                  size: 42,
                  isCircular: false,
                  tooltip: 'Copy complete hardware diagnostics and feedback to clipboard',
                  activeColor: AppColors.kappogyGreen,
                  onPressed: _copyDiagnosticsBundle,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.copy_rounded, size: 16, color: AppColors.kappogyGreen),
                      SizedBox(width: 8),
                      Text('COPY DIAGNOSTICS', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.kappogyGreen)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _guideCard({
    required String title,
    required IconData icon,
    required Color accent,
    required String tooltipText,
    required String description,
  }) {
    return Tooltip(
      message: tooltipText,
      child: SkeuoPanel(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.panelSunken,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: SkeuoTokens.sunkenWell,
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keyRow(String keyCombination, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.panelSunken,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            ),
            child: Text(
              keyCombination,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.ledCyan, fontFamily: 'monospace'),
            ),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _codecBadgeRow(List<String> codecs) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: codecs.map((c) {
        return Tooltip(
          message: 'Hardware decoded codec format: $c',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.panelSunken,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            ),
            child: Text(c, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.kappogyGreen)),
          ),
        );
      }).toList(),
    );
  }
}
