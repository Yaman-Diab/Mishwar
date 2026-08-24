import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignUp implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository _repository;

  const SignUp(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) {
    return _repository.signUp(
      identifier: params.identifier,
      password: params.password,
      fullName: params.fullName,
    );
  }
}

class SignUpParams extends Equatable {
  final String identifier;
  final String password;
  final String fullName;

  const SignUpParams({
    required this.identifier,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [identifier, password, fullName];
}
