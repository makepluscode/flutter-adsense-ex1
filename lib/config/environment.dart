import 'package:flutter/foundation.dart';
import 'dart:js_util' as js_util;

class Environment {
  static String get googleClientId {
    if (kIsWeb) {
      try {
        final env = js_util.getProperty(js_util.globalThis, 'env');
        return js_util.getProperty(env, 'GOOGLE_CLIENT_ID') ?? '';
      } catch (e) {
        print('Error: $e');
        return '';
      }
    }
    return '';
  }
}
