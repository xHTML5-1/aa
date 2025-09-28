import '../../../../core/network/api_client.dart';
import '../models/invoice_model.dart';
import '../models/payment_model.dart';
import '../models/period_model.dart';
import '../models/site_model.dart';

abstract class SiteRemoteDataSource {
  Future<SiteModel> fetchSite(String siteId);
  Future<List<PeriodModel>> listPeriods(String siteId);
  Future<PeriodModel> upsertPeriod(PeriodModel period);
  Future<List<InvoiceModel>> runPeriod(String siteId, PeriodModel period);
  Future<PeriodModel> publishPeriod(String siteId, String periodId);
  Future<PaymentIntentModel> createPaymentIntent(
    String siteId,
    String invoiceId,
    String gateway,
  );
  Future<void> markInvoicePaid(String siteId, String invoiceId);
}

class SiteRemoteDataSourceImpl implements SiteRemoteDataSource {
  SiteRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<SiteModel> fetchSite(String siteId) async {
    final response = await _client.get<Map<String, dynamic>>('/sites/$siteId');
    return SiteModel.fromJson(response.data!);
  }

  @override
  Future<List<PeriodModel>> listPeriods(String siteId) async {
    final response = await _client.get<List<dynamic>>('/sites/$siteId/periods');
    return response.data!
        .map(
          (dynamic item) => PeriodModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<PeriodModel> upsertPeriod(PeriodModel period) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/sites/${period.siteId}/periods',
      data: period.toJson(),
    );
    return PeriodModel.fromJson(response.data!);
  }

  @override
  Future<List<InvoiceModel>> runPeriod(String siteId, PeriodModel period) async {
    final response = await _client.post<List<dynamic>>(
      '/sites/$siteId/periods/${period.id}/run',
      data: period.toJson(),
    );
    return response.data!
        .map(
          (dynamic item) => InvoiceModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<PeriodModel> publishPeriod(String siteId, String periodId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/sites/$siteId/periods/$periodId/publish',
    );
    return PeriodModel.fromJson(response.data!);
  }

  @override
  Future<PaymentIntentModel> createPaymentIntent(
    String siteId,
    String invoiceId,
    String gateway,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/sites/$siteId/invoices/$invoiceId/payments',
      data: <String, dynamic>{'gateway': gateway},
    );
    return PaymentIntentModel.fromJson(response.data!);
  }

  @override
  Future<void> markInvoicePaid(String siteId, String invoiceId) async {
    await _client.put<void>(
      '/sites/$siteId/invoices/$invoiceId',
      data: <String, dynamic>{'status': 'paid'},
    );
  }
}
