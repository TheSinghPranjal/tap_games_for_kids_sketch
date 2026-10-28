import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Storage boundary for the reward system. Swap this for a server-backed
/// implementation to make the backend authoritative.
abstract class RewardStore {
  Future<Map<String, dynamic>?> load();

  /// Must either persist the whole document or throw.
  Future<void> save(Map<String, dynamic> document);
}

class PrefsRewardStore implements RewardStore {
  PrefsRewardStore({this.key = 'tinythink.rewards.v1'});
  final String key;

  @override
  Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {
      // Keep the corrupt copy for diagnosis instead of silently wiping it.
      await prefs.setString('$key.corrupt', raw);
      return null;
    }
  }

  @override
  Future<void> save(Map<String, dynamic> document) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(key, jsonEncode(document));
    if (!ok) throw StateError('Failed to persist rewards');
  }
}

/// In-memory store for tests; can be told to fail to simulate storage or
/// network errors.
class MemoryRewardStore implements RewardStore {
  Map<String, dynamic>? _doc;
  int failNextSaves = 0;
  int saveCount = 0;

  @override
  Future<Map<String, dynamic>?> load() async =>
      _doc == null ? null : jsonDecode(jsonEncode(_doc)) as Map<String, dynamic>;

  @override
  Future<void> save(Map<String, dynamic> document) async {
    if (failNextSaves > 0) {
      failNextSaves--;
      throw StateError('Simulated save failure');
    }
    saveCount++;
    _doc = jsonDecode(jsonEncode(document)) as Map<String, dynamic>;
  }
}
