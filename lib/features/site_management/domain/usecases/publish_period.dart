import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/period.dart';
import '../repositories/site_repository.dart';

class PublishPeriodParams {
  const PublishPeriodParams({
    required this.siteId,
    required this.periodId,
  });

  final String siteId;
  final String periodId;
}

class PublishPeriod extends UseCase<Period, PublishPeriodParams> {
  PublishPeriod(this.repository);

  final SiteRepository repository;

  @override
  EitherFailureOr<Period> call(PublishPeriodParams params) async {
    try {
      final period =
          await repository.publishPeriod(params.siteId, params.periodId);
      return Right(period);
    } catch (error) {
      return Left(NetworkFailure(message: error.toString()));
    }
  }
}
