import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../repositories/auth_repository.dart';

@injectable
class RequestPasswordReset implements UseCase<void, RequestPasswordResetParams> {
  final AuthRepository _repository;

  const RequestPasswordReset(this._repository);

  @override
  Future<Either<Failure, void>> call(RequestPasswordResetParams params) {
    return _repository.requestPasswordReset(identifier: params.identifier);
  }
}

class RequestPasswordResetParams extends Equatable {
  final String identifier;

  const RequestPasswordResetParams({required this.identifier});

  @override
  List<Object?> get props => [identifier];
}
