package com.kappogy.musicos.kappogy_music_os_pro

import android.content.Context
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val AUDIO_CHANNEL = "com.kappogy.musicos/native_audio"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL).setMethodCallHandler { call, result ->
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

            when (call.method) {
                "getNativeAudioDeviceInfo" -> {
                    val info = mutableMapOf<String, Any>()
                    info["sampleRate"] = audioManager.getProperty(AudioManager.PROPERTY_OUTPUT_SAMPLE_RATE) ?: "44100"
                    info["framesPerBuffer"] = audioManager.getProperty(AudioManager.PROPERTY_OUTPUT_FRAMES_PER_BUFFER) ?: "256"
                    
                    var isBluetoothConnected = false
                    var isHeadsetConnected = false

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
                        for (device in devices) {
                            if (device.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP || device.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO) {
                                isBluetoothConnected = true
                            }
                            if (device.type == AudioDeviceInfo.TYPE_WIRED_HEADSET || device.type == AudioDeviceInfo.TYPE_WIRED_HEADPHONES) {
                                isHeadsetConnected = true
                            }
                        }
                    } else {
                        @Suppress("DEPRECATION")
                        isBluetoothConnected = audioManager.isBluetoothA2dpOn
                        @Suppress("DEPRECATION")
                        isHeadsetConnected = audioManager.isWiredHeadsetOn
                    }

                    info["isBluetoothConnected"] = isBluetoothConnected
                    info["isHeadsetConnected"] = isHeadsetConnected
                    info["isMusicActive"] = audioManager.isMusicActive
                    info["maxVolume"] = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                    info["currentVolume"] = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)

                    result.success(info)
                }
                "requestAudioFocus" -> {
                    @Suppress("DEPRECATION")
                    val focusResult = audioManager.requestAudioFocus(
                        null,
                        AudioManager.STREAM_MUSIC,
                        AudioManager.AUDIOFOCUS_GAIN
                    )
                    result.success(focusResult == AudioManager.AUDIOFOCUS_REQUEST_GRANTED)
                }
                "abandonAudioFocus" -> {
                    @Suppress("DEPRECATION")
                    val focusResult = audioManager.abandonAudioFocus(null)
                    result.success(focusResult == AudioManager.AUDIOFOCUS_REQUEST_GRANTED)
                }
                else -> result.notImplemented()
            }
        }
    }
}
