import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/period.dart';
import '../repositories/site_repository.dart';

class ListPeriods extends UseCase<List<Period>, String> {
  ListPeriods(this.repository);

  final SiteRepository repository;

  @override
  EitherFailureOr<List<Period>> call(String params) async {
    try {
      final periods = await repository.listPeriods(params);
      return Right(periods);
    } catch (error) {
      return Left(NetworkFailure(message: error.toString()));
    }
  }
}
