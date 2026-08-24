import 'package:equatable/equatable.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashDestinationOnboarding extends SplashState {
  const SplashDestinationOnboarding();
}

class SplashDestinationLogin extends SplashState {
  const SplashDestinationLogin();
}
