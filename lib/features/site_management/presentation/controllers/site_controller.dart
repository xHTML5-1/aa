import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/notification_service.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/period.dart';
import '../../domain/usecases/create_payment_intent.dart';
import '../../domain/usecases/get_site.dart';
import '../../domain/usecases/list_periods.dart';
import '../../domain/usecases/mark_invoice_paid.dart';
import '../../domain/usecases/publish_period.dart';
import '../../domain/usecases/run_period.dart';
import '../state/site_state.dart';

class SiteController extends StateNotifier<SiteState> {
  SiteController({
    required GetSite getSite,
    required ListPeriods listPeriods,
    required RunPeriod runPeriod,
    required PublishPeriod publishPeriod,
    required CreatePaymentIntent createPaymentIntent,
    required MarkInvoicePaid markInvoicePaid,
    required NotificationService notificationService,
  })  : _getSite = getSite,
        _listPeriods = listPeriods,
        _runPeriod = runPeriod,
        _publishPeriod = publishPeriod,
        _createPaymentIntent = createPaymentIntent,
        _markInvoicePaid = markInvoicePaid,
        _notificationService = notificationService,
        super(const SiteState());

  final GetSite _getSite;
  final ListPeriods _listPeriods;
  final RunPeriod _runPeriod;
  final PublishPeriod _publishPeriod;
  final CreatePaymentIntent _createPaymentIntent;
  final MarkInvoicePaid _markInvoicePaid;
  final NotificationService _notificationService;

  Future<void> loadSite(String siteId) async {
    state = state.copyWith(isLoading: true, resetError: true);
    final siteResult = await _getSite(siteId);
    siteResult.fold(
      (failure) => _setError(failure),
      (site) async {
        state = state.copyWith(site: site);
        final periodsResult = await _listPeriods(siteId);
        periodsResult.fold(
          (failure) => _setError(failure),
          (periods) => state = state.copyWith(
            periods: periods,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future<void> runPeriod(String siteId, Period period) async {
    state = state.copyWith(isLoading: true, resetError: true);
    final result = await _runPeriod(RunPeriodParams(siteId: siteId, period: period));
    result.fold(
      (failure) => _setError(failure),
      (invoices) {
        state = state.copyWith(isLoading: false, invoices: invoices);
      },
    );
  }

  Future<void> publishPeriod(String siteId, String periodId) async {
    state = state.copyWith(isLoading: true, resetError: true);
    final result = await _publishPeriod(
      PublishPeriodParams(siteId: siteId, periodId: periodId),
    );
    result.fold(
      (failure) => _setError(failure),
      (period) {
        final updatedPeriods = state.periods.map((existing) {
          if (existing.id == period.id) {
            return period;
          }
          return existing;
        }).toList();
        state = state.copyWith(isLoading: false, periods: updatedPeriods);
      },
    );
  }

  Future<void> collectPayment(
    String siteId,
    String invoiceId,
    String gateway,
  ) async {
    state = state.copyWith(isLoading: true, resetError: true);
    final result = await _createPaymentIntent(
      CreatePaymentIntentParams(
        siteId: siteId,
        invoiceId: invoiceId,
        gateway: gateway,
      ),
    );
    result.fold(
      (failure) => _setError(failure),
      (intent) async {
        final updatedInvoices = state.invoices.map((invoice) {
          if (invoice.id == intent.invoiceId) {
            return invoice.copyWith(paymentStatus: 'processing');
          }
          return invoice;
        }).toList();
        state = state.copyWith(isLoading: false, invoices: updatedInvoices);
        await _notificationService.sendLocalLog('Ödeme başlatıldı: ${intent.invoiceId}');
      },
    );
  }

  Future<void> markInvoicePaid(String siteId, String invoiceId) async {
    final result = await _markInvoicePaid(
      MarkInvoicePaidParams(siteId: siteId, invoiceId: invoiceId),
    );
    result.fold(
      (failure) => _setError(failure),
      (_) async {
        final updatedInvoices = state.invoices.map((invoice) {
          if (invoice.id == invoiceId) {
            return invoice.copyWith(paymentStatus: 'paid');
          }
          return invoice;
        }).toList();
        state = state.copyWith(invoices: updatedInvoices);
        await _notificationService.sendLocalLog('Fatura ödendi: $invoiceId');
      },
    );
  }

  void _setError(Failure failure) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: failure.message ?? 'Beklenmeyen bir hata oluştu',
    );
  }
}
