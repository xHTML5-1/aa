import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/cache/offline_cache.dart';
import '../models/invoice_model.dart';

abstract class SiteLocalDataSource {
  Future<void> cacheInvoices(List<InvoiceModel> invoices);
  Future<List<InvoiceModel>> getCachedInvoices();
  Future<void> enqueueSync(Map<String, dynamic> payload);
  Future<List<OfflineCacheQueueItem>> queuedSyncs();
  Future<void> clearSyncItem(String key);
}

class SiteLocalDataSourceImpl implements SiteLocalDataSource {
  SiteLocalDataSourceImpl(this._prefs, this._cache);

  final SharedPreferences _prefs;
  final OfflineCache _cache;
  static const _invoiceKey = 'cached_invoices';

  @override
  Future<void> cacheInvoices(List<InvoiceModel> invoices) async {
    await _prefs.setString(
      _invoiceKey,
      jsonEncode(invoices.map((invoice) => invoice.toJson()).toList()),
    );
  }

  @override
  Future<List<InvoiceModel>> getCachedInvoices() async {
    final value = _prefs.getString(_invoiceKey);
    if (value == null) {
      return <InvoiceModel>[];
    }
    final decoded = jsonDecode(value) as List;
    return decoded
        .map((dynamic item) => InvoiceModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  @override
  Future<void> enqueueSync(Map<String, dynamic> payload) async {
    await _cache.enqueue(payload);
  }

  @override
  Future<List<OfflineCacheQueueItem>> queuedSyncs() async {
    return _cache.fetch();
  }

  @override
  Future<void> clearSyncItem(String key) async {
    await _cache.clearItem(key);
  }
}
