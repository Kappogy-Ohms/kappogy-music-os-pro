import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';

enum StudioFxType { filterSweep, echoDelay, spaceReverb, analogFlanger }

class StudioFxRack extends StatefulWidget {
  final ValueChanged<StudioFxParams>? onParamsChanged;

  const StudioFxRack({super.key, this.onParamsChanged});

  @override
  State<StudioFxRack> createState() => _StudioFxRackState();
}

class _StudioFxRackState extends State<StudioFxRack> {
  StudioFxType _selectedFx = StudioFxType.filterSweep;
  bool _isFxActive = false;
  double _dryWet = 50.0;
  double _param1 = 60.0; // Cutoff / Delay Time / Room Size / Rate
  double _param2 = 40.0; // Resonance / Feedback / Damping / Depth
  Offset _xyPosition = const Offset(0.5, 0.5);

  void _notifyChange() {
    widget.onParamsChanged?.call(
      StudioFxParams(
        type: _selectedFx,
        isActive: _isFxActive,
        dryWet: _dryWet / 100.0,
        param1: _param1 / 100.0,
        param2: _param2 / 100.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SkeuoPanel(
      showCornerScrews: true,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Power Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'STUDIO HARDWARE FX PROCESSOR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              SkeuoButton(
                size: 34,
                isCircular: false,
                icon: Icons.power_settings_new_rounded,
                isActive: _isFxActive,
                activeColor: AppColors.kappogyRed,
                tooltip: _isFxActive ? 'Bypass FX' : 'Engage FX',
                onPressed: () {
                  setState(() => _isFxActive = !_isFxActive);
                  _notifyChange();
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // FX Selector Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _fxButton(StudioFxType.filterSweep, 'FILTER', Icons.graphic_eq_rounded, AppColors.ledCyan),
              _fxButton(StudioFxType.echoDelay, 'ECHO', Icons.repeat_rounded, AppColors.kappogyYellow),
              _fxButton(StudioFxType.spaceReverb, 'REVERB', Icons.surround_sound_rounded, AppColors.ledPurple),
              _fxButton(StudioFxType.analogFlanger, 'FLANGER', Icons.waves_rounded, AppColors.kappogyGreen),
            ],
          ),

          const SizedBox(height: 14),

          // Rotary Knobs & Touch XY Pad Row
          Row(
            children: [
              // Rotary Knobs Column
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SkeuoKnob(
                          value: _dryWet,
                          min: 0,
                          max: 100,
                          size: 72,
                          label: 'Dry / Wet',
                          displayValue: '${_dryWet.round()}%',
                          ledColor: AppColors.kappogyRed,
                          onChanged: (val) {
                            setState(() => _dryWet = val);
                            _notifyChange();
                          },
                        ),
                        SkeuoKnob(
                          value: _param1,
                          min: 0,
                          max: 100,
                          size: 72,
                          label: _getParam1Label(),
                          displayValue: '${_param1.round()}%',
                          ledColor: AppColors.ledCyan,
                          onChanged: (val) {
                            setState(() => _param1 = val);
                            _notifyChange();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SkeuoKnob(
                      value: _param2,
                      min: 0,
                      max: 100,
                      size: 72,
                      label: _getParam2Label(),
                      displayValue: '${_param2.round()}%',
                      ledColor: AppColors.kappogyYellow,
                      onChanged: (val) {
                        setState(() => _param2 = val);
                        _notifyChange();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Touch XY Pad Column
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOUCH XY MODULATION PAD',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onPanDown: (details) => _updateXY(details.localPosition, 150, 140),
                      onPanUpdate: (details) => _updateXY(details.localPosition, 150, 140),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.panelWell,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isFxActive ? AppColors.ledCyan.withValues(alpha: 0.5) : AppColors.borderSubtle,
                            width: 1.2,
                          ),
                          boxShadow: SkeuoTokens.sunkenWell,
                        ),
                        child: Stack(
                          children: [
                            // Center Crosshairs Grid
                            Center(child: Container(width: double.infinity, height: 1, color: AppColors.borderSubtle)),
                            Center(child: Container(height: double.infinity, width: 1, color: AppColors.borderSubtle)),

                            // Interactive Glowing Dot Cursor
                            Positioned(
                              left: (_xyPosition.dx * 130).clamp(0.0, 130.0),
                              top: (_xyPosition.dy * 120).clamp(0.0, 120.0),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isFxActive ? AppColors.ledCyan : AppColors.textMuted,
                                  border: Border.all(color: Colors.white, width: 2.0),
                                  boxShadow: _isFxActive ? SkeuoTokens.ledGlow(AppColors.ledCyan) : SkeuoTokens.raisedSm,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateXY(Offset localPos, double width, double height) {
    final dx = (localPos.dx / width).clamp(0.0, 1.0);
    final dy = (localPos.dy / height).clamp(0.0, 1.0);
    setState(() {
      _xyPosition = Offset(dx, dy);
      _param1 = dx * 100.0;
      _param2 = (1.0 - dy) * 100.0;
    });
    _notifyChange();
  }

  Widget _fxButton(StudioFxType type, String label, IconData icon, Color color) {
    final isSelected = _selectedFx == type;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFx = type);
        _notifyChange();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isSelected ? AppColors.pressedButtonGradient : AppColors.raisedButtonGradient,
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : AppColors.borderSubtle,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  ...SkeuoTokens.pressedDepth,
                  BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 6),
                ]
              : SkeuoTokens.raisedSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? color : AppColors.textMuted),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? color : AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getParam1Label() {
    switch (_selectedFx) {
      case StudioFxType.filterSweep:
        return 'Cutoff';
      case StudioFxType.echoDelay:
        return 'Time';
      case StudioFxType.spaceReverb:
        return 'Size';
      case StudioFxType.analogFlanger:
        return 'Rate';
    }
  }

  String _getParam2Label() {
    switch (_selectedFx) {
      case StudioFxType.filterSweep:
        return 'Resonance';
      case StudioFxType.echoDelay:
        return 'Feedback';
      case StudioFxType.spaceReverb:
        return 'Damping';
      case StudioFxType.analogFlanger:
        return 'Depth';
    }
  }
}

class StudioFxParams {
  final StudioFxType type;
  final bool isActive;
  final double dryWet;
  final double param1;
  final double param2;

  const StudioFxParams({
    required this.type,
    required this.isActive,
    required this.dryWet,
    required this.param1,
    required this.param2,
  });
}
