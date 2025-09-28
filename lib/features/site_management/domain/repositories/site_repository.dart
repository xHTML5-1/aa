import '../entities/invoice.dart';
import '../entities/payment.dart';
import '../entities/period.dart';
import '../entities/site.dart';

abstract class SiteRepository {
  Future<Site> fetchSite(String siteId);
  Future<List<Period>> listPeriods(String siteId);
  Future<Period> createOrUpdatePeriod(Period period);
  Future<List<Invoice>> runPeriod(String siteId, Period period);
  Future<Period> publishPeriod(String siteId, String periodId);
  Future<PaymentIntent> createPaymentIntent(
    String siteId,
    String invoiceId,
    String gateway,
  );
  Future<void> markInvoicePaid(String siteId, String invoiceId);
}
