import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class OfflineCacheQueueItem {
  OfflineCacheQueueItem({
    required this.key,
    required this.payload,
  });

  final String key;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'payload': payload,
      };

  static OfflineCacheQueueItem fromJson(Map<String, dynamic> json) {
    return OfflineCacheQueueItem(
      key: json['key'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
    );
  }
}

class OfflineCache {
  OfflineCache(this._prefs);

  final SharedPreferences _prefs;
  static const _queueKey = 'offline_queue';

  Future<void> enqueue(Map<String, dynamic> payload) async {
    final queue = await _load();
    queue.add(
      OfflineCacheQueueItem(
        key: const Uuid().v4(),
        payload: payload,
      ),
    );
    await _save(queue);
  }

  Future<List<OfflineCacheQueueItem>> fetch() async {
    return _load();
  }

  Future<void> clearItem(String key) async {
    final queue = await _load();
    queue.removeWhere((item) => item.key == key);
    await _save(queue);
  }

  Future<List<OfflineCacheQueueItem>> _load() async {
    final value = _prefs.getString(_queueKey);
    if (value == null) {
      return <OfflineCacheQueueItem>[];
    }
    final decoded = jsonDecode(value) as List;
    return decoded
        .map((dynamic item) => OfflineCacheQueueItem.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  Future<void> _save(List<OfflineCacheQueueItem> queue) async {
    await _prefs.setString(
      _queueKey,
      jsonEncode(queue.map((item) => item.toJson()).toList()),
    );
  }
}
