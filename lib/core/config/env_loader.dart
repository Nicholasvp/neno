import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/services.dart' show rootBundle;

class EnvLoader {
  EnvLoader._();

  static Map<String, String> _values = const {};
  static bool _loaded = false;

  static Future<void> load({String assetPath = 'assets/.env'}) async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(assetPath);
    _values = parse(raw);
    _loaded = true;
    dev.log('EnvLoader: ${_values.length} vars carregadas de $assetPath');
  }

  static String get(String key, {String defaultValue = ''}) {
    return _values[key] ?? defaultValue;
  }

  static Map<String, String> parse(String raw) {
    final result = <String, String>{};
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eq = trimmed.indexOf('=');
      if (eq <= 0) continue;
      final key = trimmed.substring(0, eq).trim();
      var value = trimmed.substring(eq + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      result[key] = value;
    }
    return result;
  }
}

