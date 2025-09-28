import '../../domain/entities/invoice.dart';
import '../../domain/entities/period.dart';
import '../../domain/entities/site.dart';

class SiteState {
  const SiteState({
    this.isLoading = false,
    this.site,
    this.periods = const <Period>[],
    this.invoices = const <Invoice>[],
    this.errorMessage,
  });

  final bool isLoading;
  final Site? site;
  final List<Period> periods;
  final List<Invoice> invoices;
  final String? errorMessage;

  SiteState copyWith({
    bool? isLoading,
    Site? site,
    List<Period>? periods,
    List<Invoice>? invoices,
    String? errorMessage,
    bool resetError = false,
  }) {
    return SiteState(
      isLoading: isLoading ?? this.isLoading,
      site: site ?? this.site,
      periods: periods ?? this.periods,
      invoices: invoices ?? this.invoices,
      errorMessage: resetError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
