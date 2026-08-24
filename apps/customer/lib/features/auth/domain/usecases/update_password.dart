import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../repositories/auth_repository.dart';

@injectable
class UpdatePassword implements UseCase<void, UpdatePasswordParams> {
  final AuthRepository _repository;

  const UpdatePassword(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdatePasswordParams params) {
    return _repository.updatePassword(newPassword: params.newPassword);
  }
}

class UpdatePasswordParams extends Equatable {
  final String newPassword;

  const UpdatePasswordParams({required this.newPassword});

  @override
  List<Object?> get props => [newPassword];
}
