import 'package:flutter/services.dart';

class WiFiLvlProvider {
  static const platform = const MethodChannel('zlp.heatmap1/wifi');
  static Future<int> getWifiLevel() async {
    try {
      final int result = await platform.invokeMethod('getCurWifiLevel');
      return result;
    } on PlatformException catch (e) {
      print(e.details);
      print(e.code);
      print(e.message);
      return null;
    }
  }
}