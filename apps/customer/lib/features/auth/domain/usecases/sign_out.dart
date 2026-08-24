import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:mashwar_core/mashwar_core.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignOut implements UseCase<void, NoParams> {
  final AuthRepository _repository;

  const SignOut(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.signOut();
  }
}
