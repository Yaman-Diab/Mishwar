import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

@LazySingleton(as: OnboardingRepository)
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource _local;

  const OnboardingRepositoryImpl(this._local);

  @override
  Future<Either<Failure, bool>> hasSeenOnboarding() async {
    try {
      return Right(await _local.hasSeenOnboarding());
    } catch (_) {
      return const Left(CacheFailure('onboarding_status_read_failed'));
    }
  }

  @override
  Future<Either<Failure, void>> markOnboardingSeen() async {
    try {
      await _local.markOnboardingSeen();
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure('onboarding_status_write_failed'));
    }
  }
}
