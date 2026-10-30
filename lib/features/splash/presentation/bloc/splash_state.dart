part of 'splash_bloc.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

final class SplashInitial extends SplashState {
  const SplashInitial();
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

final class SplashLoaded extends SplashState {
  const SplashLoaded(this.startup);

  final AppStartup startup;

  @override
  List<Object?> get props => [startup];
}

final class SplashFailure extends SplashState {
  const SplashFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
