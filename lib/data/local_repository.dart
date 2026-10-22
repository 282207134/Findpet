import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One versioned snapshot; writes are serialized to preserve rapid edits.
class LocalRepository {
  LocalRepository(this.preferences);
  final SharedPreferences preferences;
  static const storageKey = 'findpet.v1';
  Future<void> _pending = Future.value();
  static Future<LocalRepository> open() async =>
      LocalRepository(await SharedPreferences.getInstance());
  Map<String, dynamic> load() {
    final raw = preferences.getString(storageKey);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  Future<void> save(Map<String, dynamic> snapshot) {
    final encoded = jsonEncode(snapshot);
    _pending = _pending.catchError((Object _) {}).then((_) async {
      if (!await preferences.setString(storageKey, encoded)) {
        throw StateError('Unable to save local data');
      }
    });
    return _pending;
  }
}
