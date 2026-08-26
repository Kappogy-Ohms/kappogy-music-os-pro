import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeAudioDeviceInfo {
  final String sampleRate;
  final bool isBluetoothConnected;
  final bool isHeadsetConnected;
  final String currentRoute;
  final Map<String, dynamic> raw;

  const NativeAudioDeviceInfo({
    required this.sampleRate,
    required this.isBluetoothConnected,
    required this.isHeadsetConnected,
    required this.currentRoute,
    required this.raw,
  });
}

/// Bridge service communicating with Android (Kotlin) and iOS (Swift) native audio engines
class NativeAudioBridge {
  static const MethodChannel _channel = MethodChannel('com.kappogy.musicos/native_audio');

  static Future<NativeAudioDeviceInfo?> getDeviceInfo() async {
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('getNativeAudioDeviceInfo');
      if (res != null) {
        return NativeAudioDeviceInfo(
          sampleRate: res['sampleRate']?.toString() ?? '44100',
          isBluetoothConnected: res['isBluetoothConnected'] as bool? ?? false,
          isHeadsetConnected: res['isHeadsetConnected'] as bool? ?? false,
          currentRoute: res['currentRoute']?.toString() ?? 'System Default',
          raw: res,
        );
      }
    } catch (e) {
      debugPrint('NativeAudioBridge error: $e');
    }
    return null;
  }

  static Future<bool> requestAudioFocus() async {
    try {
      final res = await _channel.invokeMethod<bool>('requestAudioFocus');
      return res ?? true;
    } catch (_) {
      return true;
    }
  }

  static Future<void> configureAudioSession() async {
    try {
      await _channel.invokeMethod('configureAudioSession');
    } catch (_) {}
  }
}
