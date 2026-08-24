import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../repositories/auth_repository.dart';

@injectable
class VerifyPasswordResetCode implements UseCase<void, VerifyPasswordResetCodeParams> {
  final AuthRepository _repository;

  const VerifyPasswordResetCode(this._repository);

  @override
  Future<Either<Failure, void>> call(VerifyPasswordResetCodeParams params) {
    return _repository.verifyPasswordResetCode(
      identifier: params.identifier,
      code: params.code,
    );
  }
}

class VerifyPasswordResetCodeParams extends Equatable {
  final String identifier;
  final String code;

  const VerifyPasswordResetCodeParams({required this.identifier, required this.code});

  @override
  List<Object?> get props => [identifier, code];
}
