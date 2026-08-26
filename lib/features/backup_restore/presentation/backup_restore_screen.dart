import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../library/data/music_database.dart';
import '../../library/presentation/library_providers.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isProcessing = false;
  String? _statusMessage;

  Future<void> _exportBackup() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Exporting database snapshot...';
    });

    try {
      final db = MusicDatabase.instance;
      final data = await db.exportFullBackup();
      final jsonString = jsonEncode(data);

      final dir = await getApplicationDocumentsDirectory();
      final backupPath = '${dir.path}/kappogy_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File(backupPath);
      await file.writeAsString(jsonString);

      setState(() {
        _isProcessing = false;
        _statusMessage = 'Backup exported successfully to:\n$backupPath';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Export error: $e';
      });
    }
  }

  Future<void> _importBackup() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Selecting backup file...';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);

        final db = MusicDatabase.instance;
        await db.restoreBackup(data);
        await ref.read(libraryNotifierProvider.notifier).loadLibrary();

        setState(() {
          _isProcessing = false;
          _statusMessage = 'Backup restored successfully!';
        });
      } else {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Import error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chassisBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SkeuoButton(
          size: 40,
          isCircular: false,
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'OFFLINE BACKUP & RESTORE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
            shadows: SkeuoTokens.debossedText,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SkeuoPanel(
                showCornerScrews: true,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.panelSunken,
                            shape: BoxShape.circle,
                            boxShadow: SkeuoTokens.sunkenWell,
                          ),
                          child: const Icon(Icons.security_rounded, color: AppColors.kappogyGreen, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ZERO-CLOUD PRIVACY SHIELD',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            Text(
                              'Backups remain 100% on your local storage',
                              style: TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Includes playlists, star ratings, listening history, custom EQ presets, tag changes, and smart rules.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Export Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.panelRaised,
                    side: const BorderSide(color: AppColors.borderProminent, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.file_upload_rounded, color: AppColors.ledCyan),
                  label: const Text(
                    'EXPORT LOCAL BACKUP JSON',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  onPressed: _isProcessing ? null : _exportBackup,
                ),
              ),

              const SizedBox(height: 12),

              // Import Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.panelRaised,
                    side: const BorderSide(color: AppColors.borderProminent, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.file_download_rounded, color: AppColors.kappogyYellow),
                  label: const Text(
                    'IMPORT & RESTORE FROM FILE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  onPressed: _isProcessing ? null : _importBackup,
                ),
              ),

              const SizedBox(height: 20),

              if (_statusMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.panelWell,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                    boxShadow: SkeuoTokens.sunkenWell,
                  ),
                  child: Text(
                    _statusMessage!,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ledCyan),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
