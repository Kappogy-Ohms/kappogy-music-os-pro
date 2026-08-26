import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_panel.dart';

class EarTrainingQuestion {
  final String category;
  final String prompt;
  final String correctOption;
  final List<String> options;
  final double playbackFreqHz;

  const EarTrainingQuestion({
    required this.category,
    required this.prompt,
    required this.correctOption,
    required this.options,
    required this.playbackFreqHz,
  });
}

class EarTrainingGameDialog extends StatefulWidget {
  const EarTrainingGameDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const EarTrainingGameDialog(),
    );
  }

  @override
  State<EarTrainingGameDialog> createState() => _EarTrainingGameDialogState();
}

class _EarTrainingGameDialogState extends State<EarTrainingGameDialog> {
  static const List<EarTrainingQuestion> _questions = [
    EarTrainingQuestion(
      category: 'FREQUENCY DISCRIMINATION',
      prompt: 'Which frequency band was boosted in this audio sample?',
      correctOption: '1.2 kHz (Vocal Presence Mid)',
      options: ['80 Hz (Sub-Bass)', '350 Hz (Warm Low-Mid)', '1.2 kHz (Vocal Presence Mid)', '12 kHz (Air Treble)'],
      playbackFreqHz: 1200.0,
    ),
    EarTrainingQuestion(
      category: 'MUSICAL INTERVALS',
      prompt: 'Identify the interval between the two played tones:',
      correctOption: 'Perfect 5th (7 Semitones)',
      options: ['Major 3rd (4 Semitones)', 'Perfect 4th (5 Semitones)', 'Perfect 5th (7 Semitones)', 'Octave (12 Semitones)'],
      playbackFreqHz: 440.0,
    ),
    EarTrainingQuestion(
      category: 'CAMELOT HARMONIC MIXING',
      prompt: 'What is the compatible adjacent harmonic key for 8B (C Major)?',
      correctOption: '9B (G Major) / 8A (A Minor)',
      options: ['9B (G Major) / 8A (A Minor)', '3A (B Minor)', '11B (A Major)', '2B (F# Major)'],
      playbackFreqHz: 523.25,
    ),
    EarTrainingQuestion(
      category: 'SUB-BASS DETECTION',
      prompt: 'Which cutoff frequency is suitable for low-end mono summing?',
      correctOption: '90 Hz Sub-Bass',
      options: ['20 Hz Infrasonic', '90 Hz Sub-Bass', '500 Hz Midrange', '2.5 kHz Speech'],
      playbackFreqHz: 90.0,
    ),
  ];

  int _currentIndex = 0;
  int _score = 0;
  String? _selectedOption;
  bool _hasAnswered = false;

  void _onOptionSelected(String option) {
    if (_hasAnswered) return;

    final q = _questions[_currentIndex];
    final isCorrect = option == q.correctOption;

    if (isCorrect) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    setState(() {
      _selectedOption = option;
      _hasAnswered = true;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _hasAnswered = false;
      });
    } else {
      // Completed
      setState(() {
        _selectedOption = null;
        _hasAnswered = false;
        _currentIndex = 0;
        _score = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 520,
        decoration: BoxDecoration(
          color: AppColors.chassisBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle, width: 1.2),
          boxShadow: const [
            BoxShadow(color: Colors.black87, blurRadius: 30, spreadRadius: 5),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.panelSunken,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: SkeuoTokens.sunkenWell,
                        ),
                        child: const Icon(Icons.psychology_rounded, color: AppColors.kappogyGreen, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STUDIO MUSICIAN EAR TRAINING GAME',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 0.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Round ${_currentIndex + 1} of ${_questions.length} • Score: $_score/$_currentIndex',
                              style: const TextStyle(fontSize: 10, color: AppColors.kappogyGreen, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Question Card
            SkeuoPanel(
              showCornerScrews: true,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.panelSunken,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.ledCyan.withValues(alpha: 0.5), width: 0.8),
                    ),
                    child: Text(
                      q.category,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.ledCyan),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q.prompt,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.panelRaised,
                          side: const BorderSide(color: AppColors.kappogyYellow, width: 1.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, color: AppColors.kappogyYellow, size: 16),
                        label: Text('PLAY TEST TONE (${q.playbackFreqHz.toInt()}Hz)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Playing reference test tone at ${q.playbackFreqHz.toInt()}Hz...'), duration: const Duration(seconds: 1)),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Selectable Options
            Column(
              children: q.options.map((option) {
                final isSelected = _selectedOption == option;
                final isCorrect = option == q.correctOption;
                Color? btnColor;
                Color textColor = AppColors.textPrimary;

                if (_hasAnswered) {
                  if (isCorrect) {
                    btnColor = AppColors.kappogyGreen.withValues(alpha: 0.3);
                    textColor = AppColors.kappogyGreen;
                  } else if (isSelected) {
                    btnColor = AppColors.kappogyRed.withValues(alpha: 0.3);
                    textColor = AppColors.kappogyRed;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () => _onOptionSelected(option),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: btnColor ?? AppColors.panelSunken,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _hasAnswered && isCorrect
                              ? AppColors.kappogyGreen
                              : _hasAnswered && isSelected
                                  ? AppColors.kappogyRed
                                  : AppColors.borderSubtle,
                          width: 1.0,
                        ),
                        boxShadow: SkeuoTokens.sunkenWell,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor),
                            ),
                          ),
                          if (_hasAnswered && isCorrect)
                            const Icon(Icons.check_circle_rounded, color: AppColors.kappogyGreen, size: 18)
                          else if (_hasAnswered && isSelected)
                            const Icon(Icons.cancel_rounded, color: AppColors.kappogyRed, size: 18),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_hasAnswered) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kappogyGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentIndex < _questions.length - 1 ? 'NEXT QUESTION' : 'START OVER',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
