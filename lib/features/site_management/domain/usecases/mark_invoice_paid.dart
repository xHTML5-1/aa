import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/site_repository.dart';

class MarkInvoicePaidParams {
  const MarkInvoicePaidParams({
    required this.siteId,
    required this.invoiceId,
  });

  final String siteId;
  final String invoiceId;
}

class MarkInvoicePaid extends UseCase<void, MarkInvoicePaidParams> {
  MarkInvoicePaid(this.repository);

  final SiteRepository repository;

  @override
  EitherFailureOr<void> call(MarkInvoicePaidParams params) async {
    try {
      await repository.markInvoicePaid(params.siteId, params.invoiceId);
      return const Right(null);
    } catch (error) {
      return Left(NetworkFailure(message: error.toString()));
    }
  }
}
