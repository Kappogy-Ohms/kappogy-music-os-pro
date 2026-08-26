import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let audioChannelName = "com.kappogy.musicos/native_audio"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let controller = window?.rootViewController as? FlutterViewController
    let binaryMessenger = controller?.binaryMessenger ?? engineBridge.pluginRegistry.registrar(forPlugin: "KappogyNativeAudio")?.messenger()

    if let messenger = binaryMessenger {
      let audioChannel = FlutterMethodChannel(name: audioChannelName, binaryMessenger: messenger)
      audioChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        let session = AVAudioSession.sharedInstance()

        switch call.method {
        case "getNativeAudioDeviceInfo":
          var info: [String: Any] = [:]
          info["sampleRate"] = String(session.sampleRate)
          info["outputLatency"] = session.outputLatency
          info["ioBufferDuration"] = session.ioBufferDuration
          info["outputNumberOfChannels"] = session.outputNumberOfChannels

          var isBluetoothConnected = false
          var isHeadsetConnected = false

          for output in session.currentRoute.outputs {
            if output.portType == .bluetoothA2DP || output.portType == .bluetoothHFP || output.portType == .bluetoothLE {
              isBluetoothConnected = true
            }
            if output.portType == .headphones || output.portType == .headsetMic {
              isHeadsetConnected = true
            }
          }

          info["isBluetoothConnected"] = isBluetoothConnected
          info["isHeadsetConnected"] = isHeadsetConnected
          info["isOtherAudioPlaying"] = session.isOtherAudioPlaying
          info["currentRoute"] = session.currentRoute.outputs.first?.portName ?? "Default Speaker"

          result(info)

        case "configureAudioSession":
          do {
            try session.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP, .allowAirPlay])
            try session.setActive(true)
            result(true)
          } catch {
            result(FlutterError(code: "AUDIO_SESSION_ERROR", message: error.localizedDescription, details: nil))
          }

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }
}
