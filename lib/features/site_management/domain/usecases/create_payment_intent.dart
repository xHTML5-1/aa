import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment.dart';
import '../repositories/site_repository.dart';

class CreatePaymentIntentParams {
  const CreatePaymentIntentParams({
    required this.siteId,
    required this.invoiceId,
    required this.gateway,
  });

  final String siteId;
  final String invoiceId;
  final String gateway;
}

class CreatePaymentIntent
    extends UseCase<PaymentIntent, CreatePaymentIntentParams> {
  CreatePaymentIntent(this.repository);

  final SiteRepository repository;

  @override
  EitherFailureOr<PaymentIntent> call(CreatePaymentIntentParams params) async {
    try {
      final intent = await repository.createPaymentIntent(
        params.siteId,
        params.invoiceId,
        params.gateway,
      );
      return Right(intent);
    } catch (error) {
      return Left(NetworkFailure(message: error.toString()));
    }
  }
}
