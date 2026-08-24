import 'package:dartz/dartz.dart';
import 'package:mashwar_core/mashwar_core.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, bool>> hasSeenOnboarding();

  Future<Either<Failure, void>> markOnboardingSeen();
}
