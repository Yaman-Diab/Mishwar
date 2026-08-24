import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:mashwar_core/mashwar_core.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class GetCurrentUser implements UseCase<UserEntity?, NoParams> {
  final AuthRepository _repository;

  const GetCurrentUser(this._repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
