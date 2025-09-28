import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:site_aidat_management/core/cache/offline_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfflineCache', () {
    test('enqueue and fetch should persist payloads', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cache = OfflineCache(prefs);

      await cache.enqueue({'operation': 'mark_invoice_paid'});
      await cache.enqueue({'operation': 'sync_invoice'});

      final queue = await cache.fetch();

      expect(queue.length, 2);
      expect(queue.first.payload['operation'], 'mark_invoice_paid');

      await cache.clearItem(queue.first.key);
      final queueAfterClear = await cache.fetch();
      expect(queueAfterClear.length, 1);
    });
  });
}
