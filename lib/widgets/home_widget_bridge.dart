import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Flutter側からAndroidのホームウィジェットを更新する橋渡し
class HomeWidgetBridge {
  static const MethodChannel _channel = MethodChannel('habitapp/widget');

  static Future<void> update() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await _channel.invokeMethod<void>('updateWidgets');
    } on PlatformException {
      // ウィジェット更新失敗でアプリ本体の保存は止めない
    }
  }
}
