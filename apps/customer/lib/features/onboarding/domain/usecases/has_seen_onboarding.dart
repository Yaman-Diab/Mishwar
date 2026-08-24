import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../repositories/onboarding_repository.dart';

@injectable
class HasSeenOnboarding implements UseCase<bool, NoParams> {
  final OnboardingRepository _repository;

  const HasSeenOnboarding(this._repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return _repository.hasSeenOnboarding();
  }
}
