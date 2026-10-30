/// Base contract for every domain use case.
abstract interface class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Use for use cases that take no input.
final class NoParams {
  const NoParams();
}
