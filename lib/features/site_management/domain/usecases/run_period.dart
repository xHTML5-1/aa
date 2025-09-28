import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invoice.dart';
import '../entities/period.dart';
import '../repositories/site_repository.dart';

class RunPeriodParams {
  const RunPeriodParams({
    required this.siteId,
    required this.period,
  });

  final String siteId;
  final Period period;
}

class RunPeriod extends UseCase<List<Invoice>, RunPeriodParams> {
  RunPeriod(this.repository);

  final SiteRepository repository;

  @override
  EitherFailureOr<List<Invoice>> call(RunPeriodParams params) async {
    try {
      final invoices = await repository.runPeriod(params.siteId, params.period);
      return Right(invoices);
    } catch (error) {
      return Left(ValidationFailure(message: error.toString()));
    }
  }
}
