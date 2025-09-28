import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/site.dart';
import '../repositories/site_repository.dart';

class GetSite extends UseCase<Site, String> {
  GetSite(this.repository);

  final SiteRepository repository;

  @override
  EitherFailureOr<Site> call(String params) async {
    try {
      final site = await repository.fetchSite(params);
      return Right(site);
    } catch (error) {
      return Left(NetworkFailure(message: error.toString()));
    }
  }
}
