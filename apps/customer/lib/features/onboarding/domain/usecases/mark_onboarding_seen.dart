import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../repositories/onboarding_repository.dart';

@injectable
class MarkOnboardingSeen implements UseCase<void, NoParams> {
  final OnboardingRepository _repository;

  const MarkOnboardingSeen(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.markOnboardingSeen();
  }
}
