import '../../../../core/errors/failures.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/period.dart';
import '../../domain/entities/site.dart';
import '../../domain/repositories/site_repository.dart';
import '../datasources/site_local_data_source.dart';
import '../datasources/site_remote_data_source.dart';
import '../models/period_model.dart';

class SiteRepositoryImpl implements SiteRepository {
  SiteRepositoryImpl(this.remoteDataSource, this.localDataSource);

  final SiteRemoteDataSource remoteDataSource;
  final SiteLocalDataSource localDataSource;

  @override
  Future<Site> fetchSite(String siteId) async {
    return remoteDataSource.fetchSite(siteId);
  }

  @override
  Future<List<Period>> listPeriods(String siteId) async {
    return remoteDataSource.listPeriods(siteId);
  }

  @override
  Future<Period> createOrUpdatePeriod(Period period) async {
    final periodModel = period is PeriodModel
        ? period
        : PeriodModel(
            id: period.id,
            name: period.name,
            siteId: period.siteId,
            expenses: period.expenses,
            status: period.status,
            generatedInvoices: period.generatedInvoices,
            createdAt: period.createdAt,
          );
    return remoteDataSource.upsertPeriod(periodModel);
  }

  @override
  Future<List<Invoice>> runPeriod(String siteId, Period period) async {
    final periodModel = period is PeriodModel
        ? period
        : PeriodModel(
            id: period.id,
            name: period.name,
            siteId: period.siteId,
            expenses: period.expenses,
            status: period.status,
            generatedInvoices: period.generatedInvoices,
            createdAt: period.createdAt,
          );
    final invoices = await remoteDataSource.runPeriod(siteId, periodModel);
    await localDataSource.cacheInvoices(invoices);
    return invoices;
  }

  @override
  Future<Period> publishPeriod(String siteId, String periodId) async {
    return remoteDataSource.publishPeriod(siteId, periodId);
  }

  @override
  Future<PaymentIntent> createPaymentIntent(
    String siteId,
    String invoiceId,
    String gateway,
  ) async {
    return remoteDataSource.createPaymentIntent(siteId, invoiceId, gateway);
  }

  @override
  Future<void> markInvoicePaid(String siteId, String invoiceId) async {
    try {
      await remoteDataSource.markInvoicePaid(siteId, invoiceId);
    } catch (error) {
      await localDataSource.enqueueSync(
        <String, dynamic>{
          'operation': 'mark_invoice_paid',
          'site_id': siteId,
          'invoice_id': invoiceId,
        },
      );
      throw CacheFailure(message: error.toString());
    }
  }
}
