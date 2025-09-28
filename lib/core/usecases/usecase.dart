import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

typedef EitherFailureOr<T> = Future<Either<Failure, T>>;

typedef StreamEitherFailureOr<T> = Stream<Either<Failure, T>>;

abstract class UseCase<Type, Params> {
  EitherFailureOr<Type> call(Params params);
}

class NoParams {
  const NoParams();
}
