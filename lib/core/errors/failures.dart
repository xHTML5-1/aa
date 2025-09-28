abstract class Failure {
  const Failure({this.message});

  final String? message;
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message});
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({super.message});
}
