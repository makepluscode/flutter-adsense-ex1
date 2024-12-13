import 'package:flutter/foundation.dart';
import 'dart:js_util' as js_util;

class Environment {
  static String get googleClientId {
    if (kIsWeb) {
      try {
        final env = js_util.getProperty(js_util.globalThis, 'env');
        if (env != null) {
          return js_util.getProperty(env, 'GOOGLE_CLIENT_ID') ?? '';
        }
        print('Environment variables are not set in window.env');
        return '';
      } catch (e) {
        print('Error reading environment variables: $e');
        return '';
      }
    }
    return '';
  }
}
